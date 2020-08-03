function Assignment3_HoughTransform()
% Best Practices
  clc, close all

  lineCount = 3  % Number of lines we want to detect
  
  %% STEP 1. Select image
%  im = imread('c:/material/EE8374CV/HW3/hwkHoughTransform/kanizsa.png');
  im = imread('c:/material/EE8374CV/HW3/hwkHoughTransform/runway.jpg');

  im = im2double(rgb2gray(im));
  %% STEP 2. Threshold gradient or use Canny edge detector
  imTh = edge(im,'canny');
  %% STEP 3. Build Hough Accumulator
  [HS,T,R] = houghTransform_for_Lines(imTh);
  
  %% STEP 4. Detect local maxima in Hough Space
  % Use built-in function provided by MATLAB
  % does non-maximum suppression for you
  P  = houghpeaks(HS,lineCount);  

  % Display hough space image & overlay peaks 
  figure
    imshow(HS,[],'XData',T,'YData',R,'InitialMagnification','fit');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal, hold on
    plot(T(P(:,2)),R(P(:,1)),'s','color','white');
  brighten(gcf,0.2);
  colormap copper
  title('Hough Space Diagram','fontsize',12,'fontname','Courier New');
  
  %% STEP 4. Detect local maxima in Hough Space
  plotHoughLines(im, R(P(:,1)), T(P(:,2)) );
  
end

