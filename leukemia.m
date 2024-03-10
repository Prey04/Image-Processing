clc;
clear all;
close all;
warning off;

[filename, pathname] = uigetfile('*.*', 'Select an image');
if ~ischar(filename) 
    return;
end

tic;

filepath = fullfile(pathname, filename);
I = imread(filepath);
I = imresize(I,[1368 1712]);

hsv=rgb2hsv(I);
s=hsv(:,:,2);       % saturation

[m, ~]=kmeans(s(:),3);
m=reshape(m,size(s,1),size(s,2));
B1=labeloverlay(s,m);

% Figure 1=================
figure
subplot(1,2,1), imshow(I), title('Original');
subplot(1,2,2), imshow(B1), title('kmeans');

hsv=rgb2hsv(B1);
h=hsv(:,:,1);
s=hsv(:,:,2);
v=hsv(:,:,3);  % intensity

I32 = imbinarize(v-s);

B32 = bwareaopen(I32,200);      % binary image used

% Figure 2====================
figure
imshow(B32), title('bwareaopen v-s');

M32 = I.*repmat(uint8(B32),[1,1,3]);    %mask used

% Figure 3====================
figure
imshow(M32), title('using v-s');

[B,L] = bwboundaries(B32,'noholes');

% Figure 4====================
figure
imshow(I)
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
end

wbc = k;

%% RBC==============
b1 = imbinarize(I(:,:,3));
b1 = 1-b1;

b2 = bwareaopen(b1,100);

% Figure 5====================
figure
imshow(b2)

b3 = imfill(b2,'holes');

se = strel('disk',5,4);     % structuring element
b4 = imdilate(b3,se);
b4 = imfill(b4,'holes');

% Figure 6====================
figure
imshow(b4)

[ct,rd] = imfindcircles(b4,[30 80],'ObjectPolarity','bright','Sensitivity',0.95);
figure
imshow(b4)
circ = viscircles(ct,rd);

rbc = length(rd) - wbc;

ratio = wbc/rbc;

if(ratio<0.03)
    disp("Leukemia absent");
else
    disp("Leukemia detected");
end

elapsed_time = toc