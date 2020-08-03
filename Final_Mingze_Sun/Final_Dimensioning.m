function Final_Dimensioning()
  clc, close all;
  
  FILENAME = 'FedEx_Box2_PCL_300.txt';
  
  TOF_Sensor_Specs = struct('numRows',240,'numCols',320 );
  
  % Read data from file
  [~,Intensity_Distorted,Depth_Distorted] = ...
    readPCL_data(TOF_Sensor_Specs, FILENAME);  
  
  % I_Distorted is the intensity image (with radial distortion)
  % Depth_Distorted is the depth image (with radial distortion)  
  
  % Camera intrinsic matrix
  IntrinsicMatrix = eye(3);
  IntrinsicMatrix(1,1) = 225.607;
  IntrinsicMatrix(1,3) = 158.205;       
  IntrinsicMatrix(2,2) = 224.547;
  IntrinsicMatrix(2,3) = 118.488;
  %
  % Radial distortion coefficients
  k1 = -0.202793;
  k2 = 0.176023;
  k3 = -0.0887613;
  % Tangential distortion coefficients
  p1 = 0.000450451;
  p2 = -0.000485368;
  %  
  figure(1)
    imshow( Intensity_Distorted,[],'initialMagnification','fit' ),colorbar
  figure(2)
    imshow( Depth_Distorted,[],'initialMagnification','fit' ),colorbar
  
%% STEP-1: Pre-processing
  cameraParams = cameraParameters('IntrinsicMatrix',IntrinsicMatrix','RadialDistortion',[k1, k2, k3],'TangentialDistortion',[p1,p2]); 
  % Remove lens distortion from Intensity image
  Intensity_Undistorted = undistortImage(Intensity_Distorted, cameraParams);
  % Remove lens distortion from Depth map
  Depth_Undistorted = undistortImage(Depth_Distorted, cameraParams);  
  figure(3)
  imshow( Intensity_Undistorted,[],'initialMagnification','fit' ),colorbar
  figure(4)
  imshow( log(Depth_Undistorted),[],'initialMagnification','fit' ),colorbar  
  % Define ROI
  ROI_undistI = Intensity_Undistorted(80:180,60:260);
  ROI_undistD = Depth_Undistorted(80:180,60:260);
  figure(5)
    imshow( ROI_undistI,[],'initialMagnification','fit' );
  figure(6)
    imshow( ROI_undistD,[],'initialMagnification','fit' );
%% STEP-2: Process histogram of depths
  % Identify depth of points on box
  figure(7)
  [counts,centers] = hist(ROI_undistD(:),10);
  arrange_counts = sort(counts);
  bar(centers,counts);
  Z_box = centers(counts==arrange_counts(end-1));
  % Identify depth of points on conveyor belt
  Z_conveyor = centers(counts==arrange_counts(end));
  % Identify height of box
  H = Z_conveyor - Z_box;
  
%% STEP-3: Compute corners of box
  figure(8)
  ROI = ROI_undistI+ROI_undistD;  
  imshow(ROI,[],'initialMagnification','fit');
  %use harris corner detector
  corners = detectHarrisFeatures(ROI);
  %pick 4 corners of box
  corners = corners.selectStrongest(4);
  figure(9)
  imshow(ROI_undistI,[],'initialMagnification','fit');hold on
  plot(corners.Location(:,1),corners.Location(:,2),'r+');
%% STEP-4: Compute world coordinates of box corners starting from pixel coordinates
  %sort X of corners
  corners_X_sort = sort(corners.Location(:,1));
  %get the leftmost corner of box
  corners_L = [corners_X_sort(1),min(corners.Location(corners.Location(:,1)==corners_X_sort(1),2))];
  %get the rightmost corner of box
  corners_R = [corners_X_sort(end),max(corners.Location(corners.Location(:,1)==corners_X_sort(end),2))];
  %sort Y of corners
  corners_Y_sort = sort(corners.Location(:,2));
  %get the top corner of box
  corners_T = [max(corners.Location(corners.Location(:,2)==corners_Y_sort(1),1)),corners_Y_sort(1)];
  %get the bottom corner of box
  corners_B = [min(corners.Location(corners.Location(:,2)==corners_Y_sort(end),1)),corners_Y_sort(end)];

%% STEP-5: Report dimensions of box
  %convert the pixel corner to world coordinate
  pixel_L = [corners_L(1),corners_L(2),1]';
  world_L = [1,1,Z_box]';
  world_L = Z_box*inv(IntrinsicMatrix)*pixel_L;
  
  pixel_R = [corners_R(1),corners_R(2),1]';
  world_R = [1,1,Z_box]';
  world_R = Z_box*inv(IntrinsicMatrix)*pixel_R;
  
  pixel_T = [corners_T(1),corners_T(2),1]';
  world_T = [1,1,Z_box]';
  world_T = Z_box*inv(IntrinsicMatrix)*pixel_T;
  
  pixel_B = [corners_B(1),corners_B(2),1]';
  world_B = [1,1,Z_box]';
  world_B = Z_box*inv(IntrinsicMatrix)*pixel_B;
  %compute length and width
  Length1 = sqrt((world_L(1)-world_T(1))^2+(world_L(2)-world_T(2))^2);
  Length2 = sqrt((world_B(1)-world_R(1))^2+(world_B(2)-world_R(2))^2);
  Width1 = sqrt((world_L(1)-world_B(1))^2+(world_L(2)-world_B(2))^2);
  Width2 = sqrt((world_T(1)-world_R(1))^2+(world_T(2)-world_R(2))^2);
  
  Final_Length = (Length1+Length2)/2;
  Final_Width = (Width1+Width2)/2;
end

