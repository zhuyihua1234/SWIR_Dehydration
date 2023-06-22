% Plot 3D scatter graph for dehydration parameters
% Change the name after "readtable" to the name of your Excelsheet
% Click Run
% Author: Yihua Zhu

tbl = readtable('3Dplot_test.xlsx');
S = 100
scatter3(tbl.x1950Rate, tbl.x1950Fit_Ifin, tbl.x1950Delay, S,'filled',"red")
hold on
scatter3(tbl.x1950Rate_1, tbl.x1950Fit_Ifin_1, tbl.x1950Delay_1, S,'filled',"blue")
hold off
grid on
legend('active', 'arrested')

