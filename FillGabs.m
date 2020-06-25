function BW_out = FillGabs(img,BW_in,N)

% N = 20; % Number of clusters
img = imresize(img,size(BW_in));

BW_out = false(size(BW_in)); %Preallocation
[L,NumLabels] = superpixels(img,N); %Building clusters


for i=1:NumLabels
    mask = L==i;
    tmp = bsxfun(@times, BW_in, cast(mask, 'like', BW_in));
    tmp = bwconvhull(tmp);
    BW_out = BW_out | tmp;
    
end

BW_out = imfill(BW_out,'holes');
