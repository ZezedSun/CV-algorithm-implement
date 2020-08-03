% Inputs:
%   im - [nR x nC] image
%
% Outputs: matches the output of the hough(...) function in MATLAB
%   houghSpace - Hough Transform of image (accumulator matrix)
%   theta - abscissa of Hough space (specified in degrees) 
%   rho - ordinate of Hough space (specified in pixel units)
%
function [houghSpace,theta,rho] = houghTransform_for_Lines(im) 
[r,c] = size(im);
theta = -90:90;
rho = -sqrt((r-1)^2+(c-1)^2):sqrt((r-1)^2+(c-1)^2);
houghSpace = zeros(length(rho),length(theta));
%[ye,xe] = find(im==1);
[Gx, Gy] = (imgradientxy(im));
for y = 1:r
    for x =1:c
        if im(y,x)==1 
           for k = 1:length(theta)       
           rhostar = x*cosd(theta(k))+y*sind(theta(k));
           [~,loc] = min(abs(rhostar - rho));
           houghSpace(loc,k) = houghSpace(loc,k)+1;
   %        houghSpace(loc,k) = houghSpace(loc,k)+round(sqrt(Gx(y,x)^2+Gy(y,x)^2));
           end
        end
    end
end
   filter = fspecial ('Gaussian',[3,1], 1);
%  filter = fspecial('Gaussian',[2 1], 1);% for runway.jpg
   houghSpace = round(imfilter( houghSpace, filter,'conv' ));

end