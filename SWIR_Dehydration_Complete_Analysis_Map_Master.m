% This code read dehydration raw image frames and generate maps for the
% following perameters:
    % Delta I 
    % Percent_IFin
    % Delay
    % Growth Rate (fitted by Hill Function)
% Author: Yihua Zhu

% Read all the raw ".dat" images from the folder
image_folder = pwd;
image_files = natsortfiles(dir(fullfile(image_folder, '*.dat'))); % Change the file extension to match your files
num_images = numel(image_files);
image_data = cell(num_images, 1);

for i = 1:num_images
    filename = fullfile(image_folder, image_files(i).name);
    image_data{i} = load(filename);
end

%% 
% Calculate Delta I for every Pixel
% Identify second and last frame
second_frame = load(image_files(2).name);
last_frame = load(image_files(end).name);
% Generate Delta I map
delta_I_map = last_frame - second_frame;

clear second_frame;
%% 
% Crop Lesion ROI

%Draw ROI in imfreehand and get ROI info
fontSize = 16;
imshow(last_frame, []);
axis on;
title('SWIR image', 'FontSize', fontSize);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

% Ask user to draw freehand mask.
message = sprintf('Left click and hold to begin drawing.\nSimply lift the mouse button to finish');
uiwait(msgbox(message));
hFH = imfreehand(); % Actual line of code to do the drawing.
% Create a binary image ("mask") from the ROI object.
binaryImage = hFH.createMask();
xy = hFH.getPosition;

% apply the mask to the Original image and save the cropped image as a ".TIF" file
  d=dir('*.dat');
  for i=1:length(d)
      %Reads in .dat file
      fname = d(i).name;
      raw_img=load(fname);
      blackMaskedImage = raw_img;
      blackMaskedImage(~binaryImage) = 0;
      img = blackMaskedImage * 2^(8);
      img_gray = uint16(img);
      %Converts to TIF and gives it the .tif extension
      fname = [fname(1:end-4),'.tif'];
      imwrite(img_gray,fname,'tif');
      %Reloads it in a TIF format
       A = imread(fname);
      newImage = repmat(A,[1 1 3]);
      %Rewrites in into working Directory
      imwrite(newImage,fname,'tif');
  end
%% 

% Read all the ".tif" images from the subfolder
image_files = natsortfiles(dir(fullfile(image_folder, '*.tif'))); % Change the file extension to match your files
num_images = numel(image_files);
image_data = cell(num_images, 1);

for i = 1:num_images
    filename = fullfile(image_folder, image_files(i).name);
    image_data{i} = rgb2gray(imread(filename));
end

%% 
% Generate Maps for Delay, Growth rate, and %IFin

% Create an empty matrix to store the growth rate of each pixel
growth_rate_map = zeros(size(image_data{1}));
% Create an empty matrix to store the %Ifin for each pixel
Percent_Ifin_map = zeros(size(image_data{1}));
% Create an emply matrix to store the Delay for each pixel
Delay_map = zeros(size(image_data{1}));
% Loop over each pixel and fit a Hill function to its intensity growth
for row = 1:size(image_data{1}, 1)
    for col = 1:size(image_data{1}, 2)
        y = zeros(num_images, 1);
        for i = 1:num_images
            y(i) = double(image_data{i}(row, col))/1000;
        end
     % Skip through empty pixels
        if y ~= 0
     % Fit Hill function to pixel intensity growth

     % Prepare for Hill function fit
     % Remove first frame
     y(1,:) = [];
     x = transpose(1:(num_images-1));
     maximum = max(y);
     dY_new = diff(y)./diff(x);
     slope = max(dY_new);
     halfActiv = num_images/2;
     intercept = y(2);

    % Initiate Hill Function fit

        F = @(z,xdata) z(1) +  ( (z(2)*xdata.^z(3)) ./ ...
            (z(4).^z(3)+xdata.^z(3)) ) 
        z0 = [intercept,maximum,slope,halfActiv];
try
    % finds the Hill function based on least squares fitting
    z = lsqcurvefit(F,z0,x,y); 

    % Hill Function Growth rate Output 
        HillOutput = [{[x,F(z,x)]},{[z(1),z(3),z(4),z(2)]}];
        growth_rate_map(row, col) = HillOutput{1,2}(2);
    catch
        fprintf('Inconsistent data in iteration %s, skipped.\n', i);
    end
    % Calculate %IFin
    % Find the necessary parameters to calculate %Ifin
try
        [M, tMax] = max(dY_new);
        I_tMax = y(tMax);
        I_t0 = y(1);
        I_tend = y(num_images - 1);
        I_tMaxPlus10 = y(tMax + 10);
                    catch
        fprintf('Inconsistent data in iteration %s, skipped.\n', i);
    end


    % Calculate %IFin and store the values into the empty matrix
    try
        percent_Ifin = ((I_tend - I_tMaxPlus10)/(I_tend - I_t0))*100;
        Percent_Ifin_map(row, col) = percent_Ifin;
            catch
        fprintf('Inconsistent data in iteration %s, skipped.\n', i);
    end

    % Identify Delay (first frame when derivative is larger than 2)
     try
        delay = find(dY_new > 0.5) - 1;
        Delay_map(row, col) = delay(1);
           catch
        fprintf('Inconsistent data in iteration %s, skipped.\n', i);
    end
        
      else
            growth_rate_map(row, col) = 0;
            Percent_Ifin_map(row, col) = 0;
            Delay_map(row, col) = 0;

        end
    end


end

%% 

% Step 5: Display the maps
subplot(2,2,1)
imshow(delta_I_map,[0 100])
colormap(gca, jet(256)); 
colorbar(gca);
title('Delta I')

subplot(2,2,2)
imshow(growth_rate_map,[0 3])
colormap(gca, jet(256)); 
colorbar(gca);
title('Growth Rate')

subplot(2,2,3)
imshow(Percent_Ifin_map,[0 100])
colormap(gca, flipud(jet(256))); 
colorbar(gca);
title('%IFin')

subplot(2,2,4)
imshow(Delay_map,[0 5])
colormap(gca, jet(256)); 
colorbar(gca);
title('Delay')