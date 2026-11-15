clc;
clear;
close all;

%% WHITEBOARD GLARE REDUCTION & TEXT RETRIEVAL
% Local Averaging + Linear Contrast Stretching + Fusion
% Grayscale implementation


% ---------------------------------------------------------
% 1. READ IMAGE
% ---------------------------------------------------------

inputFile = 'whiteboard.jpg';

I = imread(inputFile);

if size(I,3) == 3
    I = rgb2gray(I);
end

I = im2double(I);

[H,W] = size(I);

figure;
imshow(I);
title('Original Grayscale Image');


% ---------------------------------------------------------
% 2. SELECT FOUR CORNERS OF WHITEBOARD
% ---------------------------------------------------------

figure;
imshow(I);
title('Select Four Corners of Whiteboard');

[x,y] = ginput(4);

boardMask = poly2mask(x,y,H,W);

figure;
imshow(boardMask);
title('Selected Whiteboard Region');


% ---------------------------------------------------------
% 3. PARAMETERS
% ---------------------------------------------------------

brightnessThreshold = 0.88;

differenceThreshold = 0.04;

windowSize = 31;

minimumBoardIntensity = 0.45;

kernel = ones(windowSize,windowSize);


% ---------------------------------------------------------
% 4. IDENTIFY BRIGHT CANDIDATE PIXELS
% ---------------------------------------------------------

brightMask = (I > brightnessThreshold) & boardMask;


% ---------------------------------------------------------
% 5. IDENTIFY VALID NEIGHBOURING PIXELS
% ---------------------------------------------------------

validMask = boardMask & ...
            ~brightMask & ...
            (I >= minimumBoardIntensity);

validImage = I .* double(validMask);


% ---------------------------------------------------------
% 6. CALCULATE LOCAL NEIGHBOURHOOD AVERAGE
% ---------------------------------------------------------

localSum = conv2(validImage,kernel,'same');

localCount = conv2(double(validMask),kernel,'same');

localAverage = localSum ./ max(localCount,1);


% ---------------------------------------------------------
% 7. CALCULATE LOCAL STANDARD DEVIATION
% ---------------------------------------------------------

localSquareSum = conv2(validImage.^2,kernel,'same');

localMeanSquare = localSquareSum ./ max(localCount,1);

localVariance = max(localMeanSquare-localAverage.^2,0);

localStd = sqrt(localVariance);


% ---------------------------------------------------------
% 8. ADAPTIVE GLARE DETECTION
% ---------------------------------------------------------

adaptiveThreshold = max(differenceThreshold,1.5*localStd);

glareMask = brightMask & ...
            (I > localAverage+adaptiveThreshold);


% =========================================================
% NEW PROCESSING STARTS HERE
% =========================================================


% ---------------------------------------------------------
% 9. EXPAND GLARE REGION
% ---------------------------------------------------------

featherRadius = max(5,round(0.015*min(H,W)));

se = strel('disk',featherRadius);

glareRegion = imdilate(glareMask,se);

glareRegion = glareRegion & boardMask;


% ---------------------------------------------------------
% 10. CREATE FEATHERING WEIGHT
% ---------------------------------------------------------

distanceMap = bwdist(glareMask);

t = min(distanceMap/(featherRadius+1),1);

% Smooth transition from 1 to 0
alpha = 1-(3*t.^2-2*t.^3);

alpha(~glareRegion) = 0;


% ---------------------------------------------------------
% 11. IMPROVED PAVG - LOCAL AVERAGING
% ---------------------------------------------------------

validMask2 = boardMask & ...
             ~glareRegion & ...
             (I >= minimumBoardIntensity);

validImage2 = I .* double(validMask2);

localSum2 = conv2(validImage2,kernel,'same');

localCount2 = conv2(double(validMask2),kernel,'same');

localAverage2 = localSum2 ./ max(localCount2,1);

% Global fallback average
if any(validMask2(:))
    globalAverage = mean(I(validMask2));
else
    globalAverage = mean(I(boardMask));
end

noNeighbours = localCount2 == 0;

localAverage2(noNeighbours) = globalAverage;

% Feathered average replacement
Pavg = I;

Pavg(glareRegion) = ...
    alpha(glareRegion).*localAverage2(glareRegion) + ...
    (1-alpha(glareRegion)).*I(glareRegion);


% ---------------------------------------------------------
% 12. IMPROVED PEQ - LOCAL LINEAR CONTRAST STRETCHING
% ---------------------------------------------------------

Peq = I;

cc = bwconncomp(glareRegion);

stats = regionprops(cc,'BoundingBox');

for k = 1:cc.NumObjects

    % Bounding box
    bb = stats(k).BoundingBox;

    pad = featherRadius;

    rMin = max(1,floor(bb(2))-pad);
    rMax = min(H,ceil(bb(2)+bb(4))+pad);

    cMin = max(1,floor(bb(1))-pad);
    cMax = min(W,ceil(bb(1)+bb(3))+pad);

    % Extract local whiteboard region
    subI = I(rMin:rMax,cMin:cMax);

    subBoard = boardMask(rMin:rMax,cMin:cMax);

    subRegion = glareRegion(rMin:rMax,cMin:cMax);

    % Use surrounding whiteboard pixels
    roiValues = subI(subBoard);

    if numel(roiValues) < 2
        continue;
    end

    % Sort intensities
    sortedValues = sort(roiValues(:));

    % Robust 2nd and 98th percentile limits
    lowIndex = max(1,round(0.02*numel(sortedValues)));

    highIndex = min(numel(sortedValues), ...
                    ceil(0.98*numel(sortedValues)));

    minVal = sortedValues(lowIndex);

    maxVal = sortedValues(highIndex);

    if maxVal <= minVal
        continue;
    end

    % Linear contrast stretching
    stretchedSub = (subI-minVal)/(maxVal-minVal);

    % Clip intensity range
    stretchedSub = max(0,min(1,stretchedSub));

    % Feathered contrast enhancement
    currentRegion = Peq(rMin:rMax,cMin:cMax);

    localAlpha = alpha(rMin:rMax,cMin:cMax);

    currentRegion(subRegion) = ...
        localAlpha(subRegion).*stretchedSub(subRegion) + ...
        (1-localAlpha(subRegion)).*subI(subRegion);

    Peq(rMin:rMax,cMin:cMax) = currentRegion;

end


% ---------------------------------------------------------
% 13. FUSION USING MINIMUM OPERATOR
% ---------------------------------------------------------

finalOutputImage = I;

fusedImage = min(Pavg,Peq);

finalOutputImage(glareRegion) = fusedImage(glareRegion);


% ---------------------------------------------------------
% 14. DISPLAY RESULTS
% ---------------------------------------------------------

figure('Name','Whiteboard Glare Reduction Results', ...
       'Units','Normalized', ...
       'Position',[0.03 0.2 0.94 0.5]);

subplot(2,3,1);
imshow(I);
title('1. Original Image');

subplot(2,3,2);
imshow(glareMask);
title('2. Glare Mask');

subplot(2,3,3);
imshow(Pavg);
title('3. Improved Pavg');

subplot(2,3,4);
imshow(Peq);
title('4. Improved Peq');

subplot(2,3,5);
imshow(finalOutputImage);
title('5. Final Fused Output');

subplot(2,3,6);
imshow(glareRegion);
title('6. Expanded Glare Region');


% ---------------------------------------------------------
% 15. SAVE OUTPUTS
% ---------------------------------------------------------

imwrite(glareMask,'whiteboard_glare_mask.png');

imwrite(glareRegion,'whiteboard_glare_region.png');

imwrite(Pavg,'whiteboard_pavg.png');

imwrite(Peq,'whiteboard_peq.png');

imwrite(finalOutputImage,'whiteboard_final_recovered.png');


% ---------------------------------------------------------
% 16. DISPLAY STATISTICS
% ---------------------------------------------------------

fprintf('\n--- PROCESSING RESULTS ---\n');

fprintf('Detected glare pixels: %d\n',nnz(glareMask));

fprintf('Expanded region pixels: %d\n',nnz(glareRegion));

fprintf('Feather radius: %d pixels\n',featherRadius);

disp('Glare reduction completed successfully!');
