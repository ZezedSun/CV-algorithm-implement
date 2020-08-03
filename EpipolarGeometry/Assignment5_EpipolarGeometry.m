function Assignment5_EpipolarGeometry()
  clc, clear all, close all
  % Load VLFEAT
  run vlfeat-0.9.16/toolbox/vl_setup;
  % Load images
  im1 = imread('temple_im1.png');
  im2 = imread('temple_im2.png');
  singleIm1 = single(rgb2gray(im1));
  singleIm2 = single(rgb2gray(im2));
  % Extract SIFT keypoints & descriptors for images 1 & 2
  [frames1,descrs1] = vl_sift(singleIm1);
  [frames2,descrs2] = vl_sift(singleIm2);
  [matches,scores] = vl_ubcmatch(descrs1,descrs2,2);
  % Identify putative correspondences
  matchPoints1 = frames1(1:2,matches(1,:))';
  matchPoints2 = frames2(1:2,matches(2,:))';
  figure(1)
  showMatchedFeatures(im1,im2,matchPoints1,matchPoints2,'montage','Parent',axes); 
  % Estimate fundamental matrix
  [F,inliersIndex] = estimateFundamentalMatrix(matchPoints1,matchPoints2,'Method','LMedS',...
      'NumTrials',2000,'DistanceThreshold',1e-3);
  % Find epipoles
  v1 = null(F);
  e1 = v1./v1(3);
  v2 = null(F');
  e2 = v2./v2(3);
  % Draw epipolar lines
  validIndex = find(inliersIndex ==1)
  figure(2);
  imshow(im2);
  hold on;
  for i = 1:10
  l_prime = F*[matchPoints1(validIndex(i),1),matchPoints1(validIndex(i),2),1]';
  y_prime_first = (-l_prime(3,1)-l_prime(1,1))/l_prime(2,1);
  y_prime_end = (-l_prime(3,1)-size(im2,2)*l_prime(1,1))/l_prime(2,1);
  plot([1,size(im2,2)],[y_prime_first,y_prime_end],'y','linewidth',2);
  scatter(matchPoints2(validIndex(i),1),matchPoints2(validIndex(i),2),'r','o','filled');
  hold on;
  end
  plot(e1(1),e1(2),'b+');
  
  figure(3);
  imshow(im1);
  hold on;
  for j = 1:10
  l = F'*[matchPoints2(validIndex(j),1),matchPoints2(validIndex(j),2),1]';
  y_first = (-l(3,1)-l(1,1))/l(2,1);
  y_end = (-l(3,1)-size(im1,2)*l(1,1))/l(2,1);
  plot([1,size(im1,2)],[y_first,y_end],'y','linewidth',2);
  scatter(matchPoints1(validIndex(j),1),matchPoints1(validIndex(j),2),'r','o','filled');
  hold on;
  end
  plot(e2(1),e2(2),'b+');
end