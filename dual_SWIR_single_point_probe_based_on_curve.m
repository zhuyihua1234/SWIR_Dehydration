% This code analyzes dual wavelength dehydration data generated by single
% point dual SWIR probe
% Instructions:
    % Change the working directory to the folder containing "xlsx" file
    % copy file name into line 11
    % Optional: Set number of frames and FPS in this dehydration run
    % The default setting is at 120 frames with 60 seconds at 2 FPS
% Author: Yihua Zhu
  

%Import data
table = readtable('M24_5psi_run3.xlsx');
%Set number of frames
num_images = 120;
%Set FPS
FPS = 2;
%Remove the first frame
table(1,:) = [];
%Separate table into two wavelength
table_1950 = table(:,1);
table_1300 = table(:,2);

%% Fit 1950nm to Hill Function

%Prepare Hill function fitting parameters
x1 = transpose(1:(num_images-1))/FPS;
y1 = table2array(table_1950);
maximum = max(y1);
dY_1 = diff(y1)./diff(x1);
slope = max(dY_1);
halfActiv = num_images/(2*FPS);
intercept = y1(1);

   % Initiate Hill Function fit

        F1 = @(z1,xdata) z1(1) +  ( (z1(2)*xdata.^z1(3)) ./ ...
            (z1(4).^z1(3)+xdata.^z1(3)) ) 
        z0 = [intercept,maximum,slope,halfActiv];

% finds the Hill function based on least squares fitting
z1 = lsqcurvefit(F1,z0,x1,y1); 

% Hill Function Growth rate Output 
        HillOutput_1 = [{[x1,F1(z1,x1)]},{[z1(1),z1(3),z1(4),z1(2)]}];
% Get Hill function fitted growth rate
growth_rate_1 = HillOutput_1{1,2}(2);
% Get new arrays of x,y in the fitted Hill Function
y1_hill = HillOutput_1{1,1}(:,2);
% Y-axis of First derivative of fitted Hill Function
dy1_hill = diff(y1_hill)./diff(x1);

%% Find %Ifin for 1950nm (based on fitted curve)

[M, tMax] = max(dy1_hill);
I_tMax = y1_hill(tMax);
I_t0 = y1_hill(1);
I_tend = y1_hill(num_images-1);

if tMax + 10*FPS < (num_images - 1)
    I_tMaxPlus10 = y1_hill(tMax + 10*FPS)
else I_tMaxPlus10 = I_tend
end

percent_Ifin_1_curve = ((I_tend - I_tMaxPlus10)/(I_tend - I_t0))*100;

%% Find %Ifin for 1950nm (based on data)
[M_data, tMax_data] = max(dY_1);
I_tMax_data = y1(tMax_data);
I_t0_data = y1(1);
I_tend_data = y1(num_images-1);

if tMax_data + 10*FPS < (num_images - 1)
    I_tMaxPlus10_data = y1(tMax_data + 10*FPS)
else I_tMaxPlus10_data = I_tend_data
end

percent_Ifin_1_data = ((I_tend_data - I_tMaxPlus10_data)/(I_tend_data - I_t0_data))*100;

%% Find Delta_I for 1950nm
%calculate delta I
Imax_1 = max(y1_hill);
Imin_1 = min(y1_hill);
delta_I_1 = Imax_1 - Imin_1;
delta_I_percent_1 = (delta_I_1/Imin_1)*100;

%% Identify Delay (first frame when derivative is larger than 0.1) for 1950nm

%Generate the "horizontal line" at the beginning of the data
y1_hill_beginning = y1_hill(1:2,:);
x1_beginning = x1(1:2,:);
fitresult1 = polyfit(x1_beginning, y1_hill_beginning,1);

%Generate the "tangent line" at maximum slope
b_tangent_1 = I_tMax - M*tMax/FPS;

%Find intercept of two lines
y_horizontal_1 = @(x) fitresult1(1)*x + fitresult1(2);
y_vertical_1 = @(x) M*x + b_tangent_1;
intersection_1 = fzero(@(x) y_horizontal_1(x)-y_vertical_1(x), 1);

if abs(fitresult1(1) - M) < 0.000000001
    Delay_display_1 = 0
else Delay_display_1 = intersection_1
end

%% Fit 1300nm to Hill Function

%Prepare Hill function fitting parameters
x2 = transpose(1:(num_images-1))/2;
y2 = table2array(table_1300);
maximum = max(y2);
dY_2 = diff(y2)./diff(x2);
slope = max(dY_2);
halfActiv = num_images/(2*FPS);
intercept = y2(1);

   % Initiate Hill Function fit

        F2 = @(z2,xdata) z2(1) +  ( (z2(2)*xdata.^z2(3)) ./ ...
            (z2(4).^z2(3)+xdata.^z2(3)) ) 
        z0 = [intercept,maximum,slope,halfActiv];

% finds the Hill function based on least squares fitting
z2 = lsqcurvefit(F2,z0,x2,y2); 

% Hill Function Growth rate Output 
        HillOutput_2 = [{[x2,F2(z2,x2)]},{[z2(1),z2(3),z2(4),z2(2)]}];
% Get Hill function fitted growth rate
growth_rate_2 = HillOutput_2{1,2}(2);
% Get new arrays of x,y in the fitted Hill Function
y2_hill = HillOutput_2{1,1}(:,2);
% Y-axis of First derivative of fitted Hill Function
dy2_hill = diff(y2_hill)./diff(x2);

%% Find %Ifin for 1300nm (based on fitted curve)
[M, tMax] = max(dy2_hill);
I_tMax = y2_hill(tMax);
I_t0 = y2_hill(1);
I_tend = y2_hill(num_images-1);

if tMax + 10*FPS < (num_images - 1)
    I_tMaxPlus10 = y2_hill(tMax + 10*FPS)
else I_tMaxPlus10 = I_tend
end

percent_Ifin_2_curve = ((I_tend - I_tMaxPlus10)/(I_tend - I_t0))*100;

%% Find %Ifin for 1300nm (based on data)
[M_data, tMax_data] = max(dY_2);
I_tMax_data = y2(tMax_data);
I_t0_data = y2(1);
I_tend_data = y2(num_images-1);

if tMax_data + 10*FPS < (num_images - 1)
    I_tMaxPlus10_data = y2(tMax_data + 10*FPS)
else I_tMaxPlus10_data = I_tend_data
end

percent_Ifin_2_data = ((I_tend_data - I_tMaxPlus10_data)/(I_tend_data - I_t0_data))*100;

%% Identify Delay for 1300nm

%Generate the "horizontal line" at the beginning of the data
y2_hill_beginning = y2_hill(1:2,:);
x2_beginning = x2(1:2,:);
fitresult2 = polyfit(x2_beginning, y2_hill_beginning,1);

%Generate the "tangent line" at maximum slope
b_tangent_2 = I_tMax - M*tMax/FPS;

%Find intercept of two lines
y_horizontal_2 = @(x) fitresult2(1)*x + fitresult2(2);
y_vertical_2 = @(x) M*x + b_tangent_2;
intersection_2 = fzero(@(x) y_horizontal_2(x)-y_vertical_2(x), 1);

if abs(fitresult2(1) - M) < 0.000000001
    Delay_display_2 = 0
else Delay_display_2 = intersection_2
end

%% Find Delta_I for 1300nm
%calculate delta I
Imax_2 = max(y2_hill);
Imin_2 = min(y2_hill);
delta_I_2 = Imax_2 - Imin_2;
delta_I_percent_2 = (delta_I_2/Imin_2)*100;
%% Display figures
    %Plot 1950nm curves
    subplot(1,2,1);
    scatter(x1,y1,'k');
    hold on
    plot(x1,F1(z1,x1),'Linewidth',2,'Color','m');
    fplot(y_vertical_1,'b');
    fplot(y_horizontal_1,'r');
    xlim([0 60]);
    ylim([Imin_1 Imax_1]);
    title('1950nm');
    xlabel('Time (s)');
    ylabel('Intensity(a.u.)');

    %Plot 1300nm curves
    subplot(1,2,2);
    scatter(x2,y2,'k');
    hold on
    plot(x2,F2(z2,x2),'Linewidth',2,'Color','m');
    fplot(y_vertical_2,'b');
    fplot(y_horizontal_2,'r');
    xlim([0 60]);
    ylim([Imin_2 Imax_2]);
    title('1300nm');
    xlabel('Time (s)');
    ylabel('Intensity(a.u.)');



%% Display other dehydration parameters
fprintf('1950nm Rate = %0.2f \n', growth_rate_1)
fprintf('1950nm Percent_Ifin based on fitted curve = %0.2f \n', percent_Ifin_1_curve)
fprintf('1950nm Percent_Ifin based on data = %0.2f \n', percent_Ifin_1_data)
fprintf('1950nm Delay = %0.2f \n', Delay_display_1)
fprintf('1950nm deltaI = %0.2f \n', delta_I_1)
fprintf('1950nm deltaI_percent = %0.2f \n', delta_I_percent_1)

fprintf('1300nm Rate = %0.2f \n', growth_rate_2)
fprintf('1300nm Percent_Ifin based on fitted curve = %0.2f \n', percent_Ifin_2_curve)
fprintf('1300nm Percent_Ifin based on data = %0.2f \n', percent_Ifin_2_data)
fprintf('1300nm Delay = %0.2f \n', Delay_display_2)
fprintf('1300nm deltaI = %0.2f \n', delta_I_2)
fprintf('1300nm deltaI_percent = %0.2f \n', delta_I_percent_2)
     
