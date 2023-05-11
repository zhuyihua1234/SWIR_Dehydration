clearvars

% open directory, identify roi, define parameters

name = 'NIR/Thermal Camera Data Conversion';
prompt = {'Full File Path','File Name','FPS','Start Time(s)','Total Time(s)'};
defaultanswer = {'D:\Occlusal lesion depth project\B4_active\B4_active',...
    'K','4','0','30'};
answer = inputdlg(prompt,name,1,defaultanswer);

selpath = answer{1};
FileName = answer{2};
fps = str2double(answer(3));
startpt = fps*str2double(answer(4))+1;
totalpts = fps*str2double(answer(5))+1;

cd(selpath);

sample = load([FileName '_60.dat']);

% import data
v = VideoWriter([FileName '_raw.avi']);
open(v);
h = size(sample,1);
w = size(sample,2);
endpt = totalpts+startpt-1;
datamatrix = zeros(h,w,totalpts);
for i = startpt:endpt
    rdata = mat2gray(load([FileName '_' num2str(i) '.dat']));
    datamatrix(:,:,i-startpt+1) = rdata;
    writeVideo(v,rdata);
end
close(v);
