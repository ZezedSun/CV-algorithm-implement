function Assignment4_Blob_Detection()
  clc,close all
 
  im = imread('Dalmatian.jpg');
  im = rgb2gray(im2double(im));
  im = ( im-min(im(:)) )/( max(im(:))-min(im(:)) );
  figure;
  imshow(im);
    
  % Implement Blob Detector
  sigma_init = 2;
  k = 2^(1/4);
  N = 15;
  scaleSpace = zeros(size(im,1),size(im,2),N);
  
  for i=1:N
      sigma_n = sigma_init*(k^(i-1));
      filt_size = 2*ceil(3*sigma_n)+1;
      LoG = (sigma_n^2)*fspecial('log',filt_size,sigma_n);
      im2 = imfilter(im,LoG,'replicate');
      imshow(im);
      scaleSpace(:,:,i) = im2.^2;
      maxScaleSpace(:,:,i)=ordfilt2(im2.^2,9,ones(3,3));
  end
  for j = 1:N
  maxScaleSpace(:,:,j)=max(maxScaleSpace(:,:,max(j-1,1):min(j+1,N)),[],3);
  end
  maxScaleSpace = maxScaleSpace.*(maxScaleSpace == scaleSpace);
  lind = find(maxScaleSpace > 0.20*max(maxScaleSpace(:)));
  [r,c,d]=ind2sub(size(maxScaleSpace),lind);
  show_all_circles(im,c,r,sqrt(2)*d,'r',1);
end