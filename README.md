# Whiteboard Glare Removal Using Digital Image Processing

### Project Description:

#### Summary -

This project focuses on detecting and reducing unwanted light reflections and glare in whiteboard images while preserving the visibility of handwritten content.

The system uses classical Digital Image Processing techniques implemented in MATLAB to identify bright glare regions, estimate surrounding pixel intensities, and recover affected areas through local averaging, contrast stretching, and image fusion.

#### Course concepts used -

1. **Image Representation and Processing**
   - Grayscale conversion.
   - Image normalization using intensity scaling.
   - Binary image masks and pixel-level operations.

2. **Image Enhancement**
   - Local neighbourhood averaging.
   - Linear contrast stretching.
   - Local intensity estimation using mean and standard deviation.

3. **Morphological Image Processing**
   - Image dilation for expanding detected glare regions.
   - Distance transform for calculating pixel distances.
   - Feathering for smooth transitions between processed and unprocessed regions.

#### Additional concepts used -

1. **Adaptive Glare Detection**
   - Brightness thresholding.
   - Local statistical analysis using neighbourhood mean and standard deviation.
   - Adaptive threshold calculation for identifying glare pixels.

2. **Image Fusion and Region-Based Processing**
   - Fusion of locally averaged and contrast-enhanced images using a minimum operator.
   - Connected component analysis for processing individual glare regions.
   - Bounding-box-based local contrast enhancement.

#### Dataset -

- Input consists of whiteboard images containing unwanted light reflections and glare.
- Images can be captured using a camera or generated synthetically by introducing glare into original whiteboard images.
- The project can be tested using multiple whiteboard images with different glare intensities and positions.
- Each input image is processed individually to generate a glare-reduced output.

#### Novelty -

1. **Adaptive Glare Detection**
   - Combines global brightness thresholding with local neighbourhood statistics to identify potential glare regions more effectively.

2. **Combined Local Averaging and Contrast Enhancement**
   - Uses two complementary processing approaches: local neighbourhood averaging (Pavg) and local linear contrast stretching (Peq).

3. **Feathered Image Fusion**
   - Combines the two processed images using a minimum operator and smooth transition weights to reduce harsh boundaries and preserve surrounding image details.

### Contributors:

1. Sourabh S (PES1UG24EC212)
2. Sujith Mihira CSS (PES1UG24EC219)
3. Tejo Mourya Sura (PES1UG24EC227)

### Steps:

1. Clone Repository:
   ```bash
   git clone https://github.com/DIP-2026-MINI-PROJECT/Whiteboard-Glare-Removal-Using-DIP/tree/main
   ```

2. Open the cloned project folder in MATLAB.

3. Ensure MATLAB and the **Image Processing Toolbox** are installed.

4. Place the input whiteboard image (`whiteboard.jpg`) in the project directory.

5. Open the main MATLAB script and execute it.

   ```matlab
   main
   ```

6. Select the four corners of the whiteboard when prompted to define the processing region.

7. View the intermediate processing stages and the final glare-reduced output.

### Outputs:

The project generates the following outputs:

- **Original Grayscale Image:** Grayscale representation of the input whiteboard.
- **Glare Mask:** Binary representation of the detected glare pixels.
- **Expanded Glare Region:** Enlarged glare regions used for smooth processing.
- **Improved Pavg:** Result obtained through local neighbourhood averaging.
- **Improved Peq:** Result obtained through local linear contrast stretching.
- **Final Fused Output:** Combined result of both processing methods, aiming to reduce glare while retaining handwritten content.

The generated images are saved in PNG format.

### References:

1. Rafael C. Gonzalez and Richard E. Woods, *Digital Image Processing*, 4th Edition, Pearson.
   - Reference for fundamental image processing, enhancement, filtering, and morphological operations.

2. MathWorks Documentation – Image Processing Toolbox.
   - https://www.mathworks.com/help/images/

3. MathWorks Documentation – `poly2mask`, `bwconncomp`, and `regionprops`.
   - https://www.mathworks.com/help/images/ref/poly2mask.html
   - https://www.mathworks.com/help/images/ref/bwconncomp.html
   - https://www.mathworks.com/help/images/ref/regionprops.html

### Limitations and Future Work:

- The current implementation requires manual selection of the four whiteboard corners.
- Fixed brightness and intensity thresholds may not work equally well for all lighting conditions.
- Strong glare covering handwritten text may result in incomplete text recovery because the original information may be lost.
- The algorithm currently operates on grayscale images and does not preserve the original colour information.
- Processing performance and output quality depend on parameters such as neighbourhood window size, brightness threshold, and feathering radius.

**Future Work:**

- Automate whiteboard boundary detection.
- Develop more adaptive thresholding techniques for varying illumination conditions.
- Improve handwritten text preservation in heavily glared regions.
- Extend the implementation to colour images.
- Evaluate performance using a larger dataset with different glare patterns and intensities.
