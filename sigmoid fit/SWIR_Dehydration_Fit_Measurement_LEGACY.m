%This code fits dehydration data generated from LEGACY LABVIEW analysis program

% Instructions:
% 1. change the file directory to the folder that contains the "xls" files
% 2. convert the "xls" files into "csv" files using Excel
% 3. copy the name of the "csv" file into the readtable("") of line 13
% 4. click run
% 5. Input dehydration time (s)
% 5. OGR and %Ifin will be displayed in Command Window
% Author: Yihua Zhu

%import dehydration data
table = readtable("B4_psi25_300mA_Results.csv");

%Set dehydration time in seconds
name = 'SWIR dehydration analysis';
prompt = {'Dehydration duration(s)?','Curve Fitting Method(1 or 2): 1. Levenberg-Marquardt 2. Trust-Region'};
defaultanswer = {'60','1'};
answer = inputdlg(prompt,name,1,defaultanswer);
dehydration_time = str2double(char(answer(1)));

%remove first 3 rows to get time and intensity as X,Y
table(1:3,:) = [];
%generate time and intensity
X = transpose(0:dehydration_time);
Y = table2array(table(:,2));
%get rid of first frame
X_new = X(2:(dehydration_time+1));
Y_new = Y(2:(dehydration_time+1));
%change time axis on original table
table(:,1) = num2cell(X);

%set up fittype and options.
ft = fittype( 'a/(1+exp((c-x)/b))+d', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );

if str2double(char(answer(2))) == 1
    opts.Algorithm = 'Levenberg-Marquardt'
else
    opts.Algorithm = "Trust-Region"
end

opts.Display = 'Off';
opts.StartPoint = [1 1 1 1];

%fit model to data.
[fitresult, gof] = fit( X_new, Y_new, ft, opts );

%plot fit with data.
figure( 'Name', 'OGR fit' );
[TF,S1] = ischange(Y_new);
h = plot( fitresult, X_new, Y_new );
hold on
stairs(S1)
legend( h, 'Intensity vs. Time(s)', 'Levernberg-Marquardt Fit', 'Location', 'NorthEast', 'Interpreter', 'none' );
%label axes
xlabel( 'Time(s)', 'Interpreter', 'none' );
ylabel( 'Intensity', 'Interpreter', 'none' );
grid on

%calculate OGR
OGR = fitresult.a/fitresult.b;
fprintf('OGR = %0.2f \n', OGR)

%Prepare to get %Ifin

%generate first derivative of the dehydration curve
dY = diff(Y)./diff(X);
%resize columns of the derivative curve
dY_new = dY(2:dehydration_time);
%find maximum slope and the corresponding time tMax,t0,tMax+10,tend
[M, I] = max(dY_new);
tMax = I;
t0 = 0;
tend = dehydration_time;
tMaxPlus10 = tMax + 10;
%find corresponding intensity values
I_tMax = table2array(table(tMax+1,2));
I_t0 = table2array(table(t0+2,2));
I_tend = table2array(table(tend+1,2));
I_tMaxPlus10 = table2array(table(tMaxPlus10+1,2));
%calculate %Ifin
percent_Ifin = ((I_tend - I_tMaxPlus10)/(I_tend - I_t0))*100;
fprintf('Percent_Ifin = %0.2f \n', percent_Ifin)
%calculate delta I
Imax = max(Y_new);
Imin = min(Y_new);
delta_I = Imax - Imin;
delta_I_percent = (delta_I/Imin)*100;
fprintf('deltaI = %0.2f \n', delta_I)
fprintf('deltaI_percent = %0.2f \n', delta_I_percent)
