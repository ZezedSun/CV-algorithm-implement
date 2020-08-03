%save('calibration.mat','cameraParams');
clc;clear all;
load('calibration.mat');
im = imread('calib0008.jpg');
% imshow(im);hold on;
R=cameraParams.RotationMatrices(:,:,8);
T=cameraParams.TranslationVectors(8,:);
%  W1 = worldToImage(cameraParams,R,T,[0 0 0]);
%  W2 = worldToImage(cameraParams,R,T,[100 0 0]);
%  W3 = worldToImage(cameraParams,R,T,[0 100 0]);
%  plot([W2(1) W1(1)],[W2(2) W1(2)],'r-','LineWidth',3);
%  text(W2(1),W1(2),'Xw','FontSize',14,'Color','red');
%  plot([W3(1) W1(1)],[W3(2) W1(2)],'b-','LineWidth',3);
%  text(W3(1),W1(1),'Yw','FontSize',14,'Color','blue');
% 
% [a,b] = ginput(2);
% plot([a(1),a(2)],[b(1),b(2)]);
% viscircles([a(1),b(1)],5,'Color','b');
% viscircles([a(2),b(2)],5,'Color','b');
% P1 = pointsToWorld(cameraParams,R,T,[a(1) b(1)]);
% P2 = pointsToWorld(cameraParams,R,T,[a(2) b(2)]);
% D = sqrt((P1(1)-P2(1))^2+(P1(2)-P2(2))^2)
% 
[img,newOrigin] = undistortImage(im,cameraParams,'OutputView','full');
ptCloud = pcread('teapot.ply');
XYZ = ptCloud.Location;
XYZ = XYZ*20;
XYZ(:,1) = XYZ(:,1) - min(XYZ(:,1))+20;
XYZ(:,2) = XYZ(:,2) - min(XYZ(:,2))+20;
XYZ(:,3) = -XYZ(:,3) + max(XYZ(:,3));
tpPoints = worldToImage(cameraParams,R,T,[XYZ(:,1),XYZ(:,2),XYZ(:,3)]);
imshow(img);
hold on;
plot(tpPoints(:,1),tpPoints(:,2),'r-');

