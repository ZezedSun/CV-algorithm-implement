clc;clear;
im = imread('Syros_Ermoupolis.jpg');
sigma_start = 1;
sigma_end = 15;
R_DOF_start = 500;
R_DOF_end = 700;
R = size(im,1);
sigma = ones(R,1);
filt_size = ones(R,1);
im1 = im;
im_red = im(:,:,1);
im_green = im(:,:,2);
im_blue = im(:,:,3);
k = zeros(R_DOF_start-2,1);
for j = 0:R_DOF_start-2
    k(j+1) = 498*sin(j*(2*pi)/1992);
end
u = zeros(R-R_DOF_end-1,1);
for v = 0:R-R_DOF_end-1
    u(v+1) = (R-R_DOF_end-1)*sin(v*2*pi/((R-R_DOF_end-1)*4));
end
sigma(1:R_DOF_start-1) = sigma_end*ones(R_DOF_start-1,1)+...
    (sigma_start-sigma_end)/(R_DOF_start-2)*k;
sigma(R_DOF_end+1:end) = sigma_start*ones(R-R_DOF_end,1)+...
     (sigma_end-sigma_start)/(R-R_DOF_end-1)*u;
% sigma(1:R_DOF_start-1) = sigma_end*ones(R_DOF_start-1,1)+...
%     (sigma_start-sigma_end)/(R_DOF_start-2)*[0:R_DOF_start-2]';
%  sigma(R_DOF_end+1:end) = sigma_start*ones(R-R_DOF_end,1)+...
%      (sigma_end-sigma_start)/(R-R_DOF_end-1)*[0:R-R_DOF_end-1]';


for i =1:R_DOF_start-1
    filt_size = 2*ceil(3*sigma(i))+1;
    h = fspecial('gaussian',filt_size,sigma(i));
    im_red = imfilter(im(1:i+filt_size,:,1),h);
    im_green = imfilter(im(1:i+filt_size,:,2),h);
    im_blue = imfilter(im(1:i+filt_size,:,3),h);
    im1(i,:,1) = im_red(i,:);
    im1(i,:,2) = im_green(i,:);
    im1(i,:,3) = im_blue(i,:);
end

for i = R_DOF_end+1:R
    filt_size = 2*ceil(3*sigma(i))+1;
    h = fspecial('gaussian',filt_size,sigma(i));
    im_red = imfilter(im(i-filt_size:end,:,1),h);
    im_green = imfilter(im(i-filt_size:end,:,2),h);
    im_blue = imfilter(im(i-filt_size:end,:,3),h);
    im1(i,:,1) = im_red(filt_size,:);
    im1(i,:,2) = im_green(filt_size,:);
    im1(i,:,3) = im_blue(filt_size,:);
end
figure(1)
imshow(im1);

figure(2)
im_hsv = rgb2hsv(im1);
im_s = im_hsv(:,:,2)*2;
im_hsv(:,:,2) = im_s;
imshow(hsv2rgb(im_hsv));