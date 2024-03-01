[file,path] = uiputfile('*.*');
exportgraphics(gcf, fullfile(path,file), 'ContentType','vector');