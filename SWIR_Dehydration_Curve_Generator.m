%This code generates dehydration curve from original .DAT files
%Instructions:
% 1. copy folder directory containing the DAT files into line 18
% 2. Click Run
% 3. Make sure the current folder is the folder containing the .dat files, and click "current folder"
% 3. Draw the whole Tooth
% 4. Draw the lesion ROI
% 5. Draw a control ROI
% 6. Dehydration curve is now generated
% 7. Dehydration curve details are exported to a CSV file with the same folder
% Authors: Nick Chang, Yihua Zhu

clearvars
close all


% Select where you want to save the analysis files
savepath = pwd;
% Identify the folder with data
path = uigetdir(path);
% Find all .dat files in folder
pathcontent = dir([path '\*.dat']);

% Number of .dat files in folder
curvelength = size(pathcontent,1);

% Create matrices based on number of .dat files
finalcurve = zeros(curvelength,1);
dehydration_Lesion = zeros(curvelength,1);
dehydration_Control = zeros(curvelength,1);
dI_Lesion = strings([curvelength,1]);
dI_Control = strings([curvelength,1]);
Diff_dI = strings([curvelength,1]);

% Setting up calling string
name = char({pathcontent(1).name});
ext = name(1:end-5);

% Load Raw Image to GRAY SCALE
img_raw = load([path '/' ext num2str(1) '.dat']);
img_gray = mat2gray(img_raw)*5; %%% x5 to brighten the image 
first_img = img_gray;

%Draw ROI in imfreehand and get ROI info
fontSize = 16;
imshow(img_gray, []); 
axis on;
title([strrep(ext,'_',' ') 'Original Image'], 'FontSize', fontSize);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

%%%%% DRAW TOOTH %%%%%
dehydration_tooth = zeros(size(img_raw,1),size(img_raw,2));
% Ask user to draw freehand mask.
message_tooth = sprintf('Left click and hold to draw out TOOTH.\nSimply lift the mouse button to finish.');
uiwait(msgbox(message_tooth));
hFH_tooth = imfreehand(); % Actual line of code to do the drawing.
% Create a binary image ("mask") from the ROI object.
binaryImage_tooth = hFH_tooth.createMask();
xy_tooth = hFH_tooth.getPosition;

% Calculate the area, in pixels, that they drew.
numberOfPixels1_tooth = sum(binaryImage_tooth(:));
% Another way to calculate it that takes fractional pixels into account.
numberOfPixels2_tooth = bwarea(binaryImage_tooth);

% Get coordinates of the boundary of the freehand drawn region.
structBoundaries_tooth = bwboundaries(binaryImage_tooth);
xy_tooth = structBoundaries_tooth{1}; % Get n by 2 array of x,y coordinates.
x_tooth = xy_tooth(:, 2); % Columns.
y_tooth = xy_tooth(:, 1); % Rows.

close % Closes drawing window.

% Calculate Temperature Values for Each Pixel
stack = zeros(size(img_raw,1),size(img_raw,2),curvelength);

for loopfolder = 1:curvelength

disp(['Analyzing frame ' num2str(loopfolder) ' ...']);
% load individual .dat file
img_raw = load([path '/' ext num2str(loopfolder) '.dat']);

% Mask the images outside the mask, and display it.
% Will keep only the part of the image that's inside the mask, zero outside mask.
blackMaskedImage_tooth = img_raw;
blackMaskedImage_tooth(~binaryImage_tooth) = 0;

% Insert image into stack
stack(:,:,loopfolder) = blackMaskedImage_tooth;

end

% Find max of each pixel
intmax = max(stack,[],3);
% Difference between Max throughout dehydration and curve for each pixel
intdiff = intmax - stack;
% Integral of difference for each pixel
sumintdiff = sum(intdiff,3);

int_norm = sumintdiff/max(max(sumintdiff));%%% Normalize to max intensity
int_norm16 = int_norm*2^16-1; %%%16bit (0-65535)
int_Plot = uint16(int_norm16);

% Plot Map
fontSize = 16;
subplot(1,2,1);
imshow(int_Plot*5, []); %%% x5 to brighten the image
% colorbar;
% colormap(jet(65536));
axis on;
title([strrep(ext,'_',' ') 'Dehydration Map'], 'FontSize', fontSize);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

%%%%% DRAW LESION %%%%%
% Ask user to draw freehand mask.
message_Lesion = sprintf('Left click and hold to draw for LESION.\nSimply lift the mouse button to finish.');
uiwait(msgbox(message_Lesion));
hFH_Lesion = imfreehand(); % Actual line of code to do the drawing.
setColor(hFH_Lesion, 'red');
% Create a binary image ("mask") from the ROI object.
binaryImage_Lesion = hFH_Lesion.createMask();
xy_Lesion = hFH_Lesion.getPosition;

% Calculate the area, in pixels, that they drew.
numberOfPixels1_Lesion = sum(binaryImage_Lesion(:));
% Another way to calculate it that takes fractional pixels into account.
numberOfPixels2_Lesion = bwarea(binaryImage_Lesion);

% Get coordinates of the boundary of the freehand drawn region.
structBoundaries_Lesion = bwboundaries(binaryImage_Lesion);
xy_Lesion = structBoundaries_Lesion{1}; % Get n by 2 array of x,y coordinates.
x_Lesion = xy_Lesion(:, 2); % Columns.
y_Lesion = xy_Lesion(:, 1); % Rows.

%%%%% DRAW CONTROL %%%%%
% Ask user to draw freehand mask.
message_Control = sprintf('Left click and hold to draw for CONTROL.\nSimply lift the mouse button to finish.');
uiwait(msgbox(message_Control));
hFH_Control = imfreehand(); % Actual line of code to do the drawing.
% Create a binary image ("mask") from the ROI object.
binaryImage_Control = hFH_Control.createMask();
xy_Control = hFH_Control.getPosition;

% Calculate the area, in pixels, that they drew.
numberOfPixels1_Control = sum(binaryImage_Control(:));
% Another way to calculate it that takes fractional pixels into account.
numberOfPixels2_Control = bwarea(binaryImage_Control);

% Get coordinates of the boundary of the freehand drawn region.
structBoundaries_Control = bwboundaries(binaryImage_Control);
xy_Control = structBoundaries_Control{1}; % Get n by 2 array of x,y coordinates.
x_Control = xy_Control(:, 2); % Columns.
y_Control = xy_Control(:, 1); % Rows.

close % Closes drawing window.

% Calculate Average Temperature Values for Each Image
for loopfolder = 1:curvelength

disp(['Analyzing frame ' num2str(loopfolder) ' ...']);
% load individual .dat file
img_raw = load([path '/' ext num2str(loopfolder) '.dat']);

% Mask the images outside the mask, and display it.
% Will keep only the part of the image that's inside the mask, zero outside mask.
blackMaskedImage_Lesion = img_raw;
blackMaskedImage_Lesion(~binaryImage_Lesion) = 0;
blackMaskedImage_Control = img_raw;
blackMaskedImage_Control(~binaryImage_Control) = 0;

% Calculate the temperature means
dehydration_Lesion(loopfolder,1) = mean(blackMaskedImage_Lesion(binaryImage_Lesion));
dehydration_Control(loopfolder,1) = mean(blackMaskedImage_Control(binaryImage_Control));
end

dehydration_Lesion_min = dehydration_Lesion - min([min(dehydration_Lesion),min(dehydration_Control)]);
dehydration_Control_min = dehydration_Control - min([min(dehydration_Lesion),min(dehydration_Control)]);

%%%%% Calculate Delta Q %%%%%
dI_L = round(max(dehydration_Lesion)*curvelength-sum(dehydration_Lesion),0);
dI_C = round(max(dehydration_Control)*curvelength-sum(dehydration_Control),0);
DdI = dI_L-dI_C;
dI_Lesion(1,1) = num2str(dI_L);
dI_Control(1,1) = num2str(dI_C);
Diff_dI(1,1) = num2str(DdI);

%%%%% Generating Figure %%%%%
fig = figure('Name',['Sample ' strrep(ext,'_',' ') 'Dehydration Results'],'NumberTitle','off');
%p_all = uipanel('Title',['Sample ' strrep(ext,'_',' ')],'FontSize',20,'BackgroundColor','white','Position',[0 0 1 1],'FontWeight','bold');

% Plot TIFF Image
%p_1 = uipanel('Title',[strrep(ext,'_',' ') 'TIFF Image'],'FontSize',18,'BackgroundColor','white','Position',[0 0.5 0.25 0.5],'TitlePosition','centertop','BorderType','none','FontWeight','bold');
%imshow(tiff,'Parent',axes(p_1),'InitialMagnification','fit');
%set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

% Plot 1st Frame
p_2 = uipanel('Title',[strrep(ext,'_',' ') 'Frame ' num2str(1)],'FontSize',18,'BackgroundColor','white','Position',[0.25 0.5 0.25 0.5],'TitlePosition','centertop','BorderType','none','FontWeight','bold');
imshow(first_img,'Parent',axes(p_2),'InitialMagnification','fit');
axis on;
set(gca,'FontSize',14)
xlabel(['Pixels (' num2str(size(first_img,2)) ')'],'FontWeight','bold'); 
ylabel(['Pixels (' num2str(size(first_img,1)) ')'],'FontWeight','bold');

% Plot Last Frame
img_raw_Last = load([path '/' ext num2str(curvelength) '.dat']);
% img_org_Last = (img_raw_Last-absmin)*100;
% Last_img = uint8(img_org_Last);
Last_img = mat2gray(img_raw_Last);

p_3 = uipanel('Title',[strrep(ext,'_',' ') 'Frame ' num2str(curvelength)],'FontSize',18,'BackgroundColor','white','Position',[0.5 0.5 0.25 0.5],'TitlePosition','centertop','BorderType','none','FontWeight','bold');
imshow(Last_img,'Parent',axes(p_3),'InitialMagnification','fit');
axis on;
set(gca,'FontSize',14)
xlabel(['Pixels (' num2str(size(first_img,2)) ')'],'FontWeight','bold'); 
ylabel(['Pixels (' num2str(size(first_img,1)) ')'],'FontWeight','bold');

% Plot Dehydration Map
p_4 = uipanel('Title',[strrep(ext,'_',' ') 'Dehydration Map'],'FontSize',18,'BackgroundColor','white','Position',[0.75 0.5 0.25 0.5],'TitlePosition','centertop','BorderType','none','FontWeight','bold');
imshow(int_Plot,'Parent',axes(p_4),'InitialMagnification','fit');
colorbar;
colormap(gca,jet(65536)); % gca allow colormap to target current object
set(gca,'FontSize',14)
axis on;
xlabel(['Pixels (' num2str(size(first_img,2)) ')'],'FontWeight','bold'); 
ylabel(['Pixels (' num2str(size(first_img,1)) ')'],'FontWeight','bold');

% Plot Lesion and Control ROIs
p_7 = uipanel('Title',[strrep(ext,'_',' ') 'Frame ' num2str(curvelength) ' + ROIs'],'FontSize',18,'BackgroundColor','white','Position',[0.5 0 0.25 0.5],'TitlePosition','centertop','BorderType','none','FontWeight','bold');
imshow(Last_img,'Parent',axes(p_7),'InitialMagnification','fit');
axis on;
set(gca,'FontSize',14)
xlabel(['Pixels (' num2str(size(first_img,2)) ')'],'FontWeight','bold'); 
ylabel(['Pixels (' num2str(size(first_img,1)) ')'],'FontWeight','bold');
hold on; 
plot(x_Lesion, y_Lesion, 'r-', 'LineWidth', 2); % Plot Lesion over original image.
plot(x_Control, y_Control, 'b-', 'LineWidth', 2); % Plot Control over original image.

% Plot Dehydration Curves
xaxis = 0:curvelength-1;
p_5 = uipanel('Title',[strrep(ext,'_',' ') 'Dehydration Curves'],'FontSize',18,'BackgroundColor','white','Position',[0 0 0.5 0.5],'TitlePosition','centertop','BorderType','none','FontWeight','bold');
plot(axes(p_5), xaxis, dehydration_Lesion_min, 'r-', 'LineWidth', 2); % Define paretn axes
set(gca,'FontSize',14)
hold on;
plot(xaxis, dehydration_Control_min, 'b-', 'Linewidth', 2);
legend({'Lesion','Control'},'Location','southeast');
xlabel('Frames','FontWeight','bold'); 
ylabel('Change in Intensity (a.u.)','FontWeight','bold');

%%% Text data onto Plot
str = {['dI Lesion: ' num2str(str2double(dI_Lesion(1,1)))],['dI Control: ' num2str(str2double(dI_Control(1,1)))],['Diff. dI: ' num2str(str2double(Diff_dI(1,1)))]};
xtext = [curvelength/2, curvelength/2, curvelength/2+100];
yL = dehydration_Lesion_min(round(curvelength/2,0),1);
yC = dehydration_Control_min(round(curvelength/2,0),1);
yDiff = (max([max(dehydration_Control_min),max(dehydration_Lesion_min)])-min([min(dehydration_Lesion_min),min(dehydration_Control_min)]))/2;
ytext = [yL,yC,yDiff];
text(xtext,ytext,str,'FontSize',14);

% Plot Dehy Map + ROIs
p_8 = uipanel('Title',[strrep(ext,'_',' ') 'Dehydration Map + ROIs'],'FontSize',18,'BackgroundColor','white','Position',[0.75 0 0.25 0.5],'TitlePosition','centertop','BorderType','none','FontWeight','bold');
imshow(int_Plot,'Parent',axes(p_8),'InitialMagnification','fit');
colorbar;
colormap(gca,jet(65536)); % gca allow colormap to target current object
set(gca,'FontSize',14)
axis on;
xlabel(['Pixels (' num2str(size(first_img,2)) ')'],'FontWeight','bold'); 
ylabel(['Pixels (' num2str(size(first_img,1)) ')'],'FontWeight','bold');
hold on; 
plot(x_Lesion, y_Lesion, 'r-', 'LineWidth', 2); % Plot Lesion over original image.
plot(x_Control, y_Control, 'b-', 'LineWidth', 2); % Plot Control over original image.

%%%%% Output Data and Save Data & Figure %%%%%
% Write data to be exported to Excel
data = horzcat(dehydration_Lesion,dehydration_Control);
Lesion = dehydration_Lesion;
Control = dehydration_Control;
finaldata = table(Lesion,Control,dI_Lesion,dI_Control,Diff_dI);
% savepath = uigetdir;
filename = [savepath '/' ext 'Results.csv'];
writetable(finaldata,filename);

% Save Figure
%figname = [savepath '/' ext 'Results.png'];
%saveas(gcf,figname);

disp(['****** Analysis of Sample ' num2str(ext(1:end-1)) ' Complete ******']);
disp(' ');
disp(['Dehydration Value (Lesion): ' num2str(str2double(dI_Lesion(1,1))) ' a.u.']);
disp(' ');
disp(['Dehydration Value (Control): ' num2str(str2double(dI_Control(1,1))) ' a.u.']);
disp(' ');
disp(['Dehydration Value Difference: ' num2str(str2double(Diff_dI(1,1))) ' a.u.']);
disp(' ');
disp('************************');