% Plot 3D scatter graph for dehydration parameters
% Author: Yihua Zhu

% Read Excel file
file = uigetfile('*.xlsx');
file_for_save = erase(file,".xlsx");
tbl = readtable(file);

%% Select Z-Axis

% Select imaging modality
options = {'Integral at 0.1 Point', 'Deriv. at Start of Fit'};

% Display a dialog box to choose between the options
choice = listdlg('PromptString', 'Select a variable:', ...
                 'SelectionMode', 'single', ...
                 'ListString', options, ...
                 'Name', 'Variable Selection');

% Depending on the choice, define the selected variable
if choice == 1
    z_axis_title = 'Integral at 0.1 Point'; % Replace with the actual variable name
elseif choice == 2
    z_axis_title = 'Deriv. at Start of Fit'; % Replace with the actual variable name
else
    error('No variable selected.');
end

%% Import perameters
active_exp_fit_rate = table2array(tbl(:,1));
active_pointone_point = table2array(tbl(:,2));
active_integral = table2array(tbl(:,3));

arrested_exp_fit_rate = table2array(tbl(:,4));
arrested_pointone_point = table2array(tbl(:,5));
arrested_integral = table2array(tbl(:,6));


%%
% Generate 3D plot
S = 100;
scatter3(active_exp_fit_rate, active_pointone_point, active_integral, S,'filled',"red")
hold on
scatter3(arrested_exp_fit_rate, arrested_pointone_point, arrested_integral, S,'filled',"blue")
hold off
grid on
legend('active', 'arrested')
xlabel('Exponential Fit Rate')
ylabel('0.1 Point')
zlabel(z_axis_title)
savefig(file_for_save)

%%

%Save workspace
save(file_for_save)