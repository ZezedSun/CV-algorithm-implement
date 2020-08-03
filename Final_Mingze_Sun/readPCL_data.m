function [XYZ,I_Distorted,Depth_Distorted] = readPCL_data(tofSensor, filename)
  % Recover PCL data from captured data

  % The data is stored as an array of float's
  % Each pixel has 4 floats (X,Y,Z,I)
  % Each frames has 320 x 240 such pixels
  
  % Number of bytes in file
  s = dir(filename);
  numBytes_in_file = s.bytes;
  
  % Number of bytes per pixel
  f = zeros(1,'single'); % 4 bytes
  fAttrib = whos('f');
  numAttributes_Per_Pixel = 4; % X,Y,Z,I
  numBytes_Per_Pixel = numAttributes_Per_Pixel * fAttrib.bytes;
  
  % Number of bytes per frame
  numPixels_Per_Frame = tofSensor.numRows*tofSensor.numCols;
  numBytes_Per_Frame = numPixels_Per_Frame * numBytes_Per_Pixel;
  
  % Number of frames in file
  numFrames = numBytes_in_file/(numPixels_Per_Frame * numBytes_Per_Pixel);

  % Allocate storage for data from ToF camera
  arr = zeros(numPixels_Per_Frame * numAttributes_Per_Pixel, numFrames,'single');  
  fid_pcl = fopen(filename, 'r');
  for nn = 1 : numFrames
    arr(:,nn) = fread(fid_pcl, numPixels_Per_Frame * numAttributes_Per_Pixel, 'float' );
  end
  fclose(fid_pcl);
  
% DID NOT WORK
%   sz_arr = [ numPixels_Per_Frame * numAttributes_Per_Pixel, numFrames  ];
%   fid_pcl = fopen(filename, 'r');
%   arr = fscanf( fid_pcl,'%f', sz_arr );
%   fclose(fid_pcl);  
%   size(arr)

  % Median filtering to mitigate noise
  arr = median(arr,2);
  
% -------------------------------------------------------------------------
% Extract point cloud and intensity image from file
% -------------------------------------------------------------------------
  imTmp = zeros(tofSensor.numCols,tofSensor.numRows);

  % Every 4th element beginning with first element in <<arr>>
  % corresponds to the Xw coordinate of the scene point
  imTmp(:) = arr(1:4:end);  
  X = transpose( imTmp );         
  
  % Every 4th element beginning with second element in <<arr>>
  % corresponds to the Yw coordinate of the scene point
  imTmp(:) = arr(2:4:end);
  Y = transpose( imTmp );

  % Every 4th element beginning with third element in <<arr>>
  % corresponds to the Zw coordinate of the scene point
  imTmp(:) = arr(3:4:end);        
  Z = transpose( imTmp );
  Depth_Distorted = Z; % Need to compensate for radial distortion
  
  XYZ = [X(:) , Y(:), Z(:)];
  
  % Every 4th element beginning with fourth element in <<arr>>
  % corresponds to the Xw coordinate of the scene point
  imTmp(:) = arr(4:4:end);
  I_Distorted = transpose( imTmp ); % Need to compensate for radial distortion   
  
end
    
