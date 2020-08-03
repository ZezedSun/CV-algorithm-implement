function Assignment2_SeamCarving()
% Best Practices
  clc, close all
  %im = imread('c:/material/EE8374CV/Assignment2/hwkHybridImages/data/view.jpg');
  im = imread('c:/material/EE8374CV/Assignment2/hwkSeamCarving/Dallas-Skyline.jpg');      % Read the image
  im = im2double(rgb2gray(im)); % Convert to grayscale & double
  %
  numColumns_to_drop = 10;     
  im_reduced = reduce_width( im, numColumns_to_drop );
  
  % Display
  figure(1)
    imshow( im, 'initialmagnification','fit' ); 
    title('Original Image');
  figure(2)
    imshow( im_reduced, 'initialmagnification','fit' ); 
    title('Result of Seam Carving');
end

function im_reduced = reduce_width(im, numPixels)
  im_old = im;
  for niter = 1:numPixels
    %{
      Function that identifies optimal vertical seam
        - accepts as input an image
        - outputs the columns associated with the optimal Vertical seam
          beginning with the first row
    %}
     
    [optVertSeamPath,Mn] = findOptVertSeam( im_old );
      figure(4),imagesc(Mn);
     title('cumulative minimum energy');
    
    % MATLAB code fragment for removing vertical seam from image
    im_new = 0 * im_old(:,1:end-1); % Define storage for new image with reduced width
    % From each row, remove the column associated with the optimal vertical seam  
    for r = 1:size(im,1)
      im_new(r,:) = im_old(r,[1:optVertSeamPath(r)-1,optVertSeamPath(r)+1:end]);
    end
    % Update the image and proceed to next iteration
    im_old = im_new;
    %{
      Display the result of intermediate seam removal
    %}
    figure(101),
      % Display the image
      imshow( im_new,'initialMagnification','fit' );
      % Overlay optimal Vertical Seam
      line( optVertSeamPath,1:size(im,1) ,'color','r','linewidth',0.5 );
      % Display iteration number
      title(sprintf('Iteration %d',niter));    
    %  
    pause(0.2)
  end
  im_reduced = im_new;
end


%{
  Function to find optimum vertical seam given an image
    - accepts as input an image
    - outputs the columns associated with the optimal Vertical seam
      beginning with the first row
%}
function [optVertSeamPath,Mn] = findOptVertSeam( im_old )
  [Gx, Gy] = imgradientxy(im_old);
  E = abs(Gx)+abs(Gy);
  M(1,:)=E(1,:);
  szr = size(im_old,1);
  szl = size(im_old,2);
  for i = 2:size(im_old,1)
      for j = 1:size(im_old,2)
          if j==1
              M(i,j) = E(i,j)+ min(M(i-1,j),M(i-1,j+1));
          elseif j == szl
                  M(i,j) = E(i,j)+min(M(i-1,j-1),M(i-1,j));
             else
                  M(i,j) = E(i,j) + min(min(M(i-1,j-1), M(i-1,j)), M(i-1,j+1));
         end
      end
  end
  figure(3),imagesc(E);
  title('energy function output');
  Mn=M;
  M = padarray(M , [0,2], Inf,'both');
  [~,I]=min(M,[],2);
  optVertSwamPath = zeros(szr,1);
  optVertSwamPath(szr,1) = I(szr,1);
  im_E = imagesc(E);
  for k = szr-1:-1:1
      [~,optVertSwamPath(k,1)] = min(M(k,optVertSwamPath(k+1,1)-1:optVertSwamPath(k+1,1)+1));
      optVertSwamPath(k,1) = optVertSwamPath(k+1,1)-2 + optVertSwamPath(k,1);
  end
  optVertSeamPath(:,1) = optVertSwamPath(:,1)-2;

% imshow (imE,'initialMagnification','fit' );
% imshow( imM,'initialMagnification','fit' );

end
