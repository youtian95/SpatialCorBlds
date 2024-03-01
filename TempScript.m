MainDir = 'Opensees FEM models\MRF3';
if 0
    EQName = 'Northridge19940117';
else
    EQName = 'Chi-Chi19990920';
end
EQDir = fullfile('..\EQ Records',EQName); % 相对于MainDir
OutputDir = ['Scenario ',EQName];  % 相对于MainDir  

Scenario_2D(MainDir,EQDir,OutputDir);