function Assignment4_SIFT_Robustness()
  clc, clear all, close all
  % Load VLFEAT
  run vlfeat-0.9.16/toolbox/vl_setup;
  % Load image
  im = imread('Oxford_VGG_Graffiti_img1.ppm');
  img = single(rgb2gray(im));
  % Extract SIFT keypoints & descriptors for image-1
  %[frames,descrs] = vl_sift(img,'PeakThresh',10);
  [frames,descrs] = vl_sift(img);
  % Visualize keypoints
  figure ('Name','keypoints');
  imagesc(im);
  colormap gray;
  hold on;
  vl_plotframe(frames);
  % Visualize desriptors
  vl_plotsiftdescriptor(descrs(:,432),frames(:,432));
  title ('keypoints');
  % Check Robustness to brightness change
  f_original = frames;
  r1 = zeros(11,1);
  for delta = -100:20:100
      img_modified1 = min(max(img+delta,0),255);
      [F_modifoed1,D_modified1] = vl_sift(img_modified1,'Frames',f_original);
      [matches1,scores] = vl_ubcmatch(D_modified1, descrs);
      r1(delta/20+6) = size(matches1,2)/size(frames,2);
  end
  figure ('Name','2');
  %x = [-100,-80,-60,-40,-20,0,20,40,60,80,100];
  x1 = -100:20:100;
  y1 = r1;
  plot(x1,y1);
  title ('Robustness to brightness change');
  % Check Robustness to contrast change
  r2 = zeros(7,1);
  for gamma = 0.5:0.25:2
      img_modified2 = 255*(img/255).^gamma;
      [F_modifoed2,D_modified2] = vl_sift(img_modified2,'Frames',f_original);
      [matches2,scores] = vl_ubcmatch(D_modified2, descrs);
      r2(gamma*4-1) = size(matches2,2)/size(frames,2);
  end
  figure;
  x2 = 0.5:0.25:2;
  y2 = r2;
  plot(x2,y2);
  title ('Robustness to contrast change');
  % Check Robustness to blur
  alpha = [1,2,4,8,10];
  r3 = zeros(5,1);
  for i = 1:1:5
      h = fspecial('gaussian',[10*alpha(i)+1,10*alpha(i)+1],alpha(i));
      im2 = im2double(img);
      im3 = imfilter(im2,h);
      img_modified3 = single(im3);
      [F_modified3,D_modified3] = vl_sift(img_modified3,'Frames',f_original);
      [matches3,scores] = vl_ubcmatch(D_modified3, descrs);
      r3(i) = size(matches3,2)/size(frames,2);
  end
  figure;
  x3 = [1,2,4,8,10];
  y3 = r3;
  plot(x3,y3);
  title ('Robustness to blur');
      
end