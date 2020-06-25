% Initialization
clear,clc,close all,warning off

% load input image
f0 = imread('1.jpg');

%% Enhance lightning
f1 = imreducehaze(f0,0.4);

%% Enhance edges
f = Enhance_edges(f1);
if length(size(f1))<3
    f1 = cat(3,f1,f1,f1);
end

% set the image size to suitable value
scale = 300/(max(size(f)));
f = imresize(f,scale*size(f(:,:,1)));

%% create initial mask from edges corners
fGray = rgb2gray(f1); fGray = imresize(fGray,size(f(:,:,1)));
mask = zeros(size(f,1),size(f,2)); 
corners = detectHarrisFeatures(fGray);
% [~, corners] = extractFeatures(Igray, corners);
corners = round(corners.Location);
for i=1:length(corners(:,1))   
    mask(corners(i,2),corners(i,1)) = true;
end
mask = imdilate(mask,strel('disk',4)); 

%% Using active contour for segmentation
mask1 = FillGabs(f1,mask,100);
figure(); imshow(f0); title('Original Image'); 
set(gcf,'Position',[236,153,1449,813]); drawnow;
figure(); imshow(mask); title('Initial mask');
set(gcf,'Position',[236,153,1449,813]); drawnow;
figure(); 
title('Active contour devolopment');
mask = region_seg(f,mask,2000,0,1); %-- Run Active contour
mask = imfill(mask,'holes');
mask = bwareafilt(mask,1);
figure(); imshow(mask); title('Segmentation mask');
set(gcf,'Position',[236,153,1449,813]); drawnow;

%% Enhance mask by image processing
mask = imresize(mask,size(f1(:,:,1)));
np = min(50,round(size(mask,1)*size(mask,2)/10300));
mask = imerode(mask,strel('disk',np));   % erode image
mask = bwareafilt(mask,1);
mask = imdilate(mask,strel('disk',np));  % dialate image
% Another layer of active contour
mask = activecontour(f1, mask, 120, 'Chan-Vese','SmoothFactor',2.5,'ContractionBias',0.2);
figure();imshow(mask); title('Enhanced mask');
set(gcf,'Position',[236,153,1449,813]); drawnow;

%% Apply segmentation mask
img  = bsxfun(@times, f0, cast(mask, 'like', f0));
figure(); imshow(img),title('Segmentation result'); 
set(gcf,'Position',[236,153,1449,813]); drawnow;
warning on
