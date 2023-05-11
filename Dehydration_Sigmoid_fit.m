%This code fits dehydration data generated from legacy LABVIEW analysis program
%This version only works with Goodrich camera with 60s dehydration
% Instructions:
% 1. change the file directory to the folder that contains the "xls" files
% 2. convert the "xls" files into "csv" files using Excel
% 3. copy the name of the "csv" file into the readtable("") of line 11
% 4. click run
% Author: Yihua Zhu

%import dehydration data
table = readtable("O1_psi25_300mA_lesion1.csv");
%remove first 3 rows to get time and intensity as X,Y
table(1:3,:) = [];
%generate time and intensity
X = transpose(0:60);
Y = table2array(table(:,2));
%get rid of first frame
X_new = X(2:61);
Y_new = Y(2:61);
%change time axis on original table
table(:,1) = num2cell(X);

%set up fittype and options.
ft = fittype( 'a/(1+exp((c-x)/b))+d', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Levenberg-Marquardt';
opts.Display = 'Off';
opts.StartPoint = [1 1 1 1];

%fit model to data.
[fitresult, gof] = fit( X_new, Y_new, ft, opts );

%plot fit with data.
figure( 'Name', 'OGR fit' );
h = plot( fitresult, X_new, Y_new );
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
dY_new = dY(2:60);
%find maximum slope and the corresponding time tMax,t0,tMax+10,tend
[M, I] = max(dY_new);
tMax = I;
t0 = 0;
tend = 60;
tMaxPlus10 = tMax + 10;
%find corresponding intensity values
I_tMax = table2array(table(tMax+1,2));
I_t0 = table2array(table(t0+2,2));
I_tend = table2array(table(tend+1,2));
I_tMaxPlus10 = table2array(table(tMaxPlus10+1,2));
%calculate %Ifin
percent_Ifin = ((I_tend - I_tMaxPlus10)/(I_tend - I_t0))*100;
fprintf('Percent_Ifin = %0.2f \n', percent_Ifin)

