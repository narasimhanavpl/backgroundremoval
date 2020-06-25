function img_out = Enhance_edges(img)

% Enhance lightining
AInv = imcomplement(img);
BInv = imreducehaze(AInv,0.1);
img = imcomplement(BInv);

% img = imreducehaze(img);
img = rangefilt(img);

% Converting the RGB (color) image to gray (intensity).
if length(size(img))>2
    g=rgb2gray(img);
else
    g=img;
end

g=medfilt2(g,[3 3]); % Median filtering to remove noise.
se=strel('disk',4); % Structural element (disk of radius 1) for morphological processing.
gi=imdilate(g,se); % Dilating the gray image with the structural element.
ge=imerode(g,se); % Eroding the gray image with structural element.
gdiff=imsubtract(gi,ge); % Morphological Gradient for edges enhancement.
gdiff=mat2gray(gdiff); % Converting the class to double.
gdiff=conv2(gdiff,[1 1;1 1]); % Convolution of the double image for brightening the edges.

np = min(5,round(size(img,1)*size(img,2)/63000));
se=strel('disk',np);
gdiff=imdilate(gdiff,se); % Eroding the gray image with structural element.

img_out = cat(3,gdiff,gdiff,gdiff);
img_out = im2uint8(img_out);



