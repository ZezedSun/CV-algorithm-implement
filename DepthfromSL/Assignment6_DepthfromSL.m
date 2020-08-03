function Assignment6_DepthfromSL()
clc, close all

% Parameter of Interest
% relative ratio between the frequency of the low & high frequency illumination patterns.....(0,6) and (0,105)
  G = 16.25;    

% Read images into following variables
  % pcosL, mcosL, psinL, msinL
  % pcosH, mcosH, psinH, msinH
  pcosL = im2double(imread('pcosL.tif'));
  mcosL = im2double(imread('mcosL.tif'));
  psinL = im2double(imread('psinL.tif'));
  msinL = im2double(imread('msinL.tif'));
  pcosH = im2double(imread('pcosH.tif'));
  mcosH = im2double(imread('mcosH.tif'));
  psinH = im2double(imread('psinH.tif'));
  msinH = im2double(imread('msinH.tif'));
  
% Identify low-res phase map
  % Identify carrier frequency if unknown
  % Demodulate carrier
  
  i_cosL = 0.5*(pcosL-mcosL);
  i_sinL = 0.5*(psinL-msinL); 
  cmplx_image = complex(i_cosL,i_sinL);
  magL = fftshift(abs(fft2(cmplx_image)));
  [row,col] = find(magL==max(magL(:)));
  EtaL = row-400;
  XiL = 700 - col;
  
  [Xg,Yg] = meshgrid(0:1398,0:798);
  Xg = Xg/1398;
  Yg = Yg/798;
  ReL = cos(2*pi*(XiL*Xg+EtaL*Yg)).*i_cosL+sin(2*pi*(XiL*Xg+EtaL*Yg)).*i_sinL;
  ImL = cos(2*pi*(XiL*Xg+EtaL*Yg)).*i_sinL-sin(2*pi*(XiL*Xg+EtaL*Yg)).*i_cosL;
  cmplx_imageL = complex(ReL,ImL);
  phaseL = pi+angle(cmplx_imageL);
  imagesc(phaseL);
  colormap(gray);
% Identify High-res phase map
  % Identify carrier frequency if unknown
  % Demodulate carrier
  i_cosH = 0.5*(pcosH-mcosH);
  i_sinH = 0.5*(psinH-msinH); 
  EtaH = EtaL*G;
  XiH = XiL*G;
  ReH = cos(2*pi*(XiH*Xg+EtaH*Yg)).*i_cosH+sin(2*pi*(XiH*Xg+EtaH*Yg)).*i_sinH;
  ImH = cos(2*pi*(XiH*Xg+EtaH*Yg)).*i_sinH-sin(2*pi*(XiH*Xg+EtaH*Yg)).*i_cosH;
  cmplx_imageH = complex(ReH,ImH);
  phaseH = pi+angle(cmplx_imageH);
  imagesc(phaseH);
  colormap(gray);
  
% Phase-unwrapping  
  phase_unwrp = phaseH + 2*pi*round((G*phaseL-phaseH)/(2*pi));
  Z = 1./phase_unwrp;
  figure(1)
  imshow(phase_unwrp,[]);

% Estimate depth
  % Post-process result
  % pixels whose intensities didnt change much
  T1 = 0.025;  %% <<< YOU NEED TO PROVIDE THIS PARAMETER >>>
  bw_shadow_mask = mask_shadow_and_occlusion_pixels(pcosH,mcosH,psinH,msinH,T1);
  figure(2)
    imshow( bw_shadow_mask )
  %
  T2 = 0.002;  %% <<< YOU NEED TO PROVIDE THIS PARAMETER >>>
  bw_flying_pixel_mask = mask_flying_pixels(Z,T2);
  %
  % Combine both masks  
  bw_mask = or( bw_shadow_mask , bw_flying_pixel_mask );
  % Median filter to fill in holes
  bw_mask = medfilt2(bw_mask,[7,7],'symmetric');

  figure(101)
    imshow( bw_mask )
    title('Inavlid Pixel mask (white are invalid)');
  
  Z(bw_mask) = NaN; % Replace invalid pixels with NaN's
  figure(102)
    mesh( Z' );
    view([45,60])
  set(gcf,'Color',[0.2 0.2 0])
  set( 102,'name','Qualitative Depth Map' )
  set( 102,'numbertitle','off' )  
end


%% Helper functions needed for assignment
function bw_mask = mask_shadow_and_occlusion_pixels(pcos,mcos,psin,msin,T)
  cosimg = 0.5*(pcos-mcos);
  sinimg = 0.5*(psin-msin);
  modln_strength = sqrt( (cosimg).^2 + (sinimg).^2 );
  nrmld_modln_strength = adjustDR( modln_strength,1,0 ); % re-normalize modln_strength so it has values from 0 to 1
  bw_mask = ( nrmld_modln_strength < T );  
  assignin('base','nms',nrmld_modln_strength);
  assignin('base','bw1',bw_mask);


end

function bw_mask = mask_flying_pixels(Z,T)
  std = stdfilt(Z,ones(3));
  bw_mask = false(size(Z));
  bw_mask(std > T) = 1;  
  assignin('base','a',std);
  assignin('base','bw2',bw_mask);
  % Morhphological proceessing of binary mask
  bw_mask = bwmorph(bw_mask,'fill');
  bw_mask = bwmorph(bw_mask,'clean');
  bw_mask = bwmorph(bw_mask,'close');
  bw_mask = bwmorph(bw_mask,'spur');
  %
  CC = bwconncomp(bw_mask);
  numPixels = cellfun(@numel,CC.PixelIdxList);
  [srt,idx] = sort(numPixels,'descend');
  strt_mask = false(size(bw_mask));
  strt_mask(CC.PixelIdxList{idx(1)}) = true;
  strt_mask(CC.PixelIdxList{idx(2)}) = true;
  strt_mask(CC.PixelIdxList{idx(3)}) = true;
  %
  bw_mask = strt_mask;
end

function img = adjustDR( img,mx,mn )
  mx_img = max(img(:));
  mn_img = min(img(:));    
  img = (img-mn_img)/(mx_img-mn_img)*(mx-mn) + mn;
end

