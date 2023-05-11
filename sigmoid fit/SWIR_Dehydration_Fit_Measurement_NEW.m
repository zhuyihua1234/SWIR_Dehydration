%This code fits dehydration data generated from new MATLAB analysis program

% Instructions:
% 1. change the current folder to the folder that contains the "csv" files
% 2. copy the name of the "csv" file into the readtable("") of line 12
% 3. click run
% 4. input dehydration time for this run
% 5. OGR and %Ifin will be displayed in Command Window
% Author: Yihua Zhu

%import dehydration data
table = readtable("B9_psi30_Results.csv");
%Set dehydration time in seconds
name = 'SWIR dehydration analysis';
prompt = {'Dehydration duration(s)?','Curve Fitting Method(1 or 2): 1. Levenberg-Marquardt 2. Trust-Region'};
defaultanswer = {'60','1'};
answer = inputdlg(prompt,name,1,defaultanswer);
dehydration_time = str2double(char(answer(1)));
%remove first 4 rows to get time and intensity as X,Y, and remove set delay
table(1:4,:) = [];
%generate time and intensity
X = transpose(0:(dehydration_time - 4));
Y = table2array(table(:,1));
%change time axis on original table
table(:,1) = num2cell(X);

%Prepare to get %Ifin

%generate first derivative of the dehydration curve
dY = diff(Y)./diff(X);
%resize columns of the derivative curve
dY_new = dY(2:(dehydration_time-5));
%find maximum slope and the corresponding time tMax,t0,tMax+10,tend
[M, I] = max(dY_new);
tMax = I;
t0 = 0;
tend = dehydration_time - 3;
tMaxPlus10 = tMax + 10;
%find corresponding intensity values
I_tMax = Y(tMax);
I_t0 = Y(t0+1);
I_tend = Y(tend);
I_tMaxPlus10 = Y(tMaxPlus10+1);
%calculate %Ifin
percent_Ifin = ((I_tend - I_tMaxPlus10)/(I_tend - I_t0))*100;
fprintf('Percent_Ifin = %0.2f \n', percent_Ifin)
%calculate delta I
Imax = max(Y);
Imin = min(Y);
delta_I = Imax - Imin;
delta_I_percent = (delta_I/Imin)*100;
fprintf('deltaI = %0.2f \n', delta_I)
fprintf('deltaI_percent = %0.2f \n', delta_I_percent)
