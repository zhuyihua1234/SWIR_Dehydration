%This code fits dehydration data generated from LEGACY LABVIEW analysis
%program to a Hill Function

% Instructions:
% 1. change the file directory to the folder that contains the "xls" files
% 2. convert the "xls" files into "csv" files using Excel
% 3. copy the name of the "csv" file into the readtable("") of line 14
% 4. click run
% 5. Input dehydration time (s)
% 5. OGR and %Ifin will be displayed in Command Window
% Author: Yihua Zhu

%import dehydration data
table = readtable("O8_psi25_200mA_arrest5.xls");

%Set dehydration time in seconds
name = 'SWIR dehydration analysis';
prompt = {'Dehydration duration(s)?'};
defaultanswer = {'60'};
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


%Prepare for Hill function fit
noParam = 4;
maximum = max(Y_new);
slope = max(dY_new);
halfActiv = dehydration_time/2;
intercept = Y_new(1);
x = X_new;
y = Y_new;

%Initiate Hill Function fit
    if noParam == 3;
        F = @(z,xdata) (z(1)*xdata.^z(2))  ./ (z(3).^z(2)+xdata.^z(2));
        z0 = [maximum,slope,halfActiv];
    elseif noParam == 4;
        F = @(z,xdata) z(1) +  ( (z(2)*xdata.^z(3)) ./ ...
            (z(4).^z(3)+xdata.^z(3)) ) 
        z0 = [intercept,maximum,slope,halfActiv];
    else
        error('Error: number of input parameters (noParam) not 3 or 4');
    end

    % finds the Hill function based on least squares fitting
    z = lsqcurvefit(F,z0,x,y); 
    
    % plots data x and y as scatter points and the Hill function as a line
    figure
    [TF,S1] = ischange(y);
    scatter(x,y,'k');
    hold on
    stairs(S1)
    plot(x,F(z,x),'Linewidth',2,'Color','m');
    title([num2str(noParam) ' parameter Hill function']);
    xlabel('Time(s)');
    ylabel('Intensity(a.u.)');
    
    % Output %
    if noParam == 3;
        HillOutput = [{[x,F(z,x)]},{[z(3),z(4),z(2)]}];
    elseif noParam == 4;
        HillOutput = [{[x,F(z,x)]},{[z(1),z(3),z(4),z(2)]}];
    end

%Export Hill function fitted coefficient
hill_max = HillOutput{1,2}(4);
hill_slope = HillOutput{1,2}(2);
hill_intercept = HillOutput{1,2}(1);
hill_halfactiv = HillOutput{1,2}(3);


%calculate OGR
OGR = hill_max/hill_slope;

%Display Dehydration Coefficient
fprintf('Rate = %0.2f \n', hill_slope)
fprintf('OGR = %0.2f \n', OGR)
fprintf('Percent_Ifin = %0.2f \n', percent_Ifin)
fprintf('deltaI = %0.2f \n', delta_I)
fprintf('deltaI_percent = %0.2f \n', delta_I_percent)



