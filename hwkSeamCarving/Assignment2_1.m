%Assignment 1
image_dog = imread('c:/material/EE8374CV/Assignment2/hwkHybridImages/data/dog.bmp');
image_cat = imread('c:/material/EE8374CV/Assignment2/hwkHybridImages/data/cat.bmp');
sigma = 50;
alpha = 0.5;
h = 21;
image_dog_cat = gen_hybrid_image_Solution( image_dog, image_cat, sigma, alpha, h )
figure
imshow(image_dog_cat,'InitialMagnification','fit')

