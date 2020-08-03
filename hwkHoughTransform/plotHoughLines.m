%plotHoughLines()
% Overlays Hough lines on top of the image.
%
%Inputs:
% im - [nR x nC] image
% rho - [Nx1] perpendicular distance of the line (N such lines).
% theta_degrees - [Nx1] angle of the line (N such lines).
function plotHoughLines(im, rho, theta_degrees)
  % DISPLAY image
  [~,c] = size(im);
  figure;
    imshow(im,[],'initialMagnification','fit');
    axis on, hold on
    for j = 1:length(theta_degrees)      
        x = linspace(1,c);
        y = (rho(j)-(x-1)*cosd(theta_degrees(j)))/sind(theta_degrees(j))+1;
        line(x,y,'Color','r','LineWidth',1)
    end
    
  %{
    Line equation: rho = x * cosd(theta) + y * sind(theta)
  %}
end