% Plot 3D scatter graph for dehydration parameters
% Author: Yihua Zhu

% Read Excel file
file = uigetfile('*.xlsx');
file_for_save = erase(file,".xlsx");
tbl = readtable(file);

%%
% Generate 3D plot
S = 100;
scatter3(tbl.Deriv_AtFirstPointOfExp_Fit, tbl.IntersectionRelativeTo0_8Point, tbl.AreaBetweenTNCurvesFrom0_8PointToIntersectionPoint, S,'filled',"red")
hold on
scatter3(tbl.Deriv_AtFirstPointOfExp_Fit_1, tbl.IntersectionRelativeTo0_8Point_1, tbl.AreaBetweenTNCurvesFrom0_8PointToIntersectionPoint_1, S,'filled',"blue")
hold off
grid on
legend('active', 'arrested')
xlabel('Deriv. at Start of Fit')
ylabel('Intersection Time')
zlabel('Area Between Curves')
savefig(file_for_save)

%%

%Save workspace
save(file_for_save)