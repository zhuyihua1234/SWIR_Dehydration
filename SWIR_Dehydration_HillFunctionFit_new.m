%This code fits dehydration data generated from new MATLAB analysis program
%to a Hill Function

% Instructions:
% 1. change the current folder to the folder that contains the "csv" files
% 2. copy the name of the "csv" file into the readtable("") of line 13
% 3. click run
% 4. input dehydration time for this run
% 5. Dehydration coeficients will be displayed in Command Window
% Author: Yihua Zhu

%import dehydration data
table = readtable("B9_psi30_Results.csv");
%Set dehydration time in seconds
name = 'SWIR dehydration analysis';
prompt = {'Dehydration duration(s)?'};
defaultanswer = {'60'};
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

%calculate delta I
Imax = max(Y);
Imin = min(Y);
delta_I = Imax - Imin;
delta_I_percent = (delta_I/Imin)*100;


%Prepare for Hill function fit
noParam = 4;
maximum = max(Y);
slope = max(dY_new);
halfActiv = dehydration_time/2;
intercept = Y(1);
x = X;
y = Y;

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


