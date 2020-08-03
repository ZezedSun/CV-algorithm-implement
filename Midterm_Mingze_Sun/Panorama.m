clc, clear all;
run vlfeat-0.9.16/toolbox/vl_setup;
imds = imageDatastore({'keble_a.jpg','keble_b.jpg','keble_c.jpg'});
I_new = readimage(imds, 1);
singleImage = single(rgb2gray(I_new));
[frames,descrs] = vl_sift(singleImage);
numImages = numel(imds.Files);
tforms(numImages) = projective2d(eye(3));
imageSize = zeros(numImages,2);
for n = 2:numImages
    framesPrevious = frames;
    descrsPrevious = descrs;
    I_old = I_new;
    I_new = readimage(imds,n);
    singleImage = single(rgb2gray(I_new));
    imageSize(n,:) = size(singleImage);
    [frames,descrs] = vl_sift(singleImage);
    [matches,scores] = vl_ubcmatch(descrsPrevious,descrs);
    matchPoints1 = framesPrevious(1:2,matches(1,:))';
    matchPoints2 = frames(1:2,matches(2,:))';
    figure(n-1)
    showMatchedFeatures(I_old,I_new,matchPoints1,matchPoints2,'montage','Parent',axes);
    [tforms(n),matchPoints3, matchPoints4] = estimateGeometricTransform(matchPoints2,matchPoints1,...
        'projective','Confidence',99.9,'MaxNumTrials',2000);
    figure(n+1)
    showMatchedFeatures(I_old,I_new,matchPoints3,matchPoints4,'montage','Parent',axes);
    tforms(n).T = tforms(n).T*tforms(n-1).T;
end
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
end
avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);
Tinv = invert(tforms(centerImageIdx));

for i = 1:numel(tforms)
    tforms(i).T = tforms(i).T * Tinv.T;
end
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
end

maxImageSize = max(imageSize);

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', I_new);
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:numImages

    I = readimage(imds, i);

    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);

    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end

figure(5)
imshow(panorama)