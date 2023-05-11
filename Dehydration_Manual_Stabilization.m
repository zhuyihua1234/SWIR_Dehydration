% Description: Imports raw thermal data over time, takes user input for
% sound, lesion, and arrested areas, averages of ROI, and outputs results
% as a graph and .mat variable file.

clearvars
close all
clc

% Directory
fold = 'D:\Occlusal lesion depth project\B4_active\B4_active';
selpath = uigetdir(fold);
cd(selpath);
foldsplit = strsplit(selpath,'\');
foldname = char(foldsplit(end));
dirinfo = dir('*.dat');
FileName = dirinfo(1).name;
FileName = FileName(1:end-6);

% Find initial parameters
sample = load([FileName '_10.dat']);
name = 'IR Camera Intensity Stabilized ROI';
prompt = {'ROI Square Length','FPS','Arrested Area? (0/1)','Start Time(s)','Total Time(s)'};
defaultanswer = {'5','4','0','0','30'};
answer = inputdlg(prompt,name,1,defaultanswer);
roisquarel = str2double(answer(1));
fps = str2double(answer(2));
arrested = str2double(answer(3));
startpt = fps*str2double(answer(4))+1;
totalpts = fps*str2double(answer(5))+1;
if length(dirinfo) ~= 121
    totalpts = length(dirinfo);
end

% Initialize vars
h = size(sample,1);
w = size(sample,2);
endpt = totalpts+startpt-1;
datamatrix = zeros(h,w,totalpts);
lesionloc = zeros(2,totalpts);
soundloc = zeros(2,totalpts);
arrestedloc = zeros(2,totalpts);
lesroimatrix = zeros(roisquarel,roisquarel,totalpts);
soundroimatrix = zeros(roisquarel,roisquarel,totalpts);
arrroimatrix = zeros(roisquarel,roisquarel,totalpts);
avgroimatrix = zeros(totalpts,1);
avgroimatrix2 = zeros(totalpts,1);
avgroimatrix3 = zeros(totalpts,1);

% User input for lesion location
f = warndlg('Choose Lesion ROI!', 'Press OK');
waitfor(f);
for i = startpt:endpt
    rdata = load([FileName '_' num2str(i) '.dat']);
    datamatrix(:,:,i-startpt+1) = rdata;
    imshow(mat2gray(rdata),'InitialMagnification','fit');
    ptroi = drawpoint('Color','r');
    lesionloc(2,i) = ceil(ptroi.Position(1));
    lesionloc(1,i) = ceil(ptroi.Position(2));
end

% User input for arrested location
if arrested == 1
    f = warndlg('Choose Arrested ROI!', 'Press OK');
    waitfor(f);
    for i = startpt:endpt
        rdata = load([FileName '_' num2str(i) '.dat']);
        datamatrix(:,:,i-startpt+1) = rdata;
        imshow(mat2gray(rdata),'InitialMagnification','fit');
        ptroi = drawpoint('Color','r');
        arrestedloc(2,i) = ceil(ptroi.Position(1));
        arrestedloc(1,i) = ceil(ptroi.Position(2));
    end
end

% User input for sound location
f = warndlg('Choose Sound ROI!', 'Press OK');
waitfor(f);
for k = startpt:endpt
    imshow(mat2gray(datamatrix(:,:,k)),'InitialMagnification','fit');
    ptroi2 = drawpoint('Color','b');
    soundloc(2,k) = ceil(ptroi2.Position(1));
    soundloc(1,k) = ceil(ptroi2.Position(2));
end

% Find average intensity of input areas
for j = startpt:endpt
    lesroi = datamatrix(lesionloc(1,j)-floor(roisquarel/2):lesionloc(1,j)+floor(roisquarel/2),...
        lesionloc(2,j)-floor(roisquarel/2):lesionloc(2,j)+floor(roisquarel/2),j);
    avgroimatrix(j) = mean(mean(lesroi));
    if arrested == 1
        arrestedroi = datamatrix(arrestedloc(1,j)-floor(roisquarel/2):arrestedloc(1,j)+floor(roisquarel/2),...
            arrestedloc(2,j)-floor(roisquarel/2):arrestedloc(2,j)+floor(roisquarel/2),j);
        avgroimatrix3(j) = mean(mean(arrestedroi));
    end
    soundroi = datamatrix(soundloc(1,j)-floor(roisquarel/2):soundloc(1,j)+floor(roisquarel/2),...
        soundloc(2,j)-floor(roisquarel/2):soundloc(2,j)+floor(roisquarel/2),j);
    avgroimatrix2(j) = mean(mean(soundroi));
end

% Find contrast of input areas
tmatrix = 0:(1/fps):((totalpts-1)/fps);
t = (tmatrix(startpt:end))';
meancontmat = (avgroimatrix-avgroimatrix2)./(avgroimatrix);
if arrested == 1
    arrmeancontmat = (avgroimatrix-avgroimatrix3)./(avgroimatrix);
end

% Make figures
figure('Name','Intensity and Contrast Plots','NumberTitle','off')
tiledlayout(2,1);
nexttile
plot(t,avgroimatrix,'r');
if arrested == 1
    hold on
    plot(t,avgroimatrix3,'m')
end
title('Lesion & Sound Intensity Over Time')
xlabel('Time (s)');
ylabel('Intensity (Arb. Units)');
hold on
plot(t,avgroimatrix2,'b');
if arrested == 0
    legend('Lesion','Sound');
elseif arrested == 1
    legend('Lesion','Sound Dentin','Sound Enamel')
end
hold off
nexttile
plot(t,meancontmat);
if arrested == 1
    hold on
    plot(t, arrmeancontmat)
end
if arrested == 1
    legend('Lesion-Enamel','Lesion-Dentin');
end
title('Contrast Over Time');
ylabel('Contrast');
xlabel('Time (s)');
hold off

x0=300;
y0=300;
width=600;
height=1000;
set(gcf,'position',[x0,y0,width,height])

% Save important variables as .mat files for future use, save results graph
if arrested == 0
    saveas(gcf,[fold '\NIR analysis\' foldname '.png']);
    save([fold '\NIR analysis\' foldname '_variables.mat'],'soundloc','lesionloc','avgroimatrix',...
        'avgroimatrix2','meancontmat');
elseif arrested == 1
    saveas(gcf,[fold '\NIR analysis\' foldname '.png']);
    save([fold '\NIR analysis\' foldname '_variables.mat'],'soundloc','lesionloc','arrestedloc',...
        'avgroimatrix','avgroimatrix2','avgroimatrix3','meancontmat','arrmeancontmat');
end