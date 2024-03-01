function EDPCell = Temp_EDPMat_2_EDPCell(EDPMat)
% 输入：
% EDPMat - Drift(i_EQ,i_IM,i_XorY,i_story)
% 
% 输出：
% EDPMat - Drift{i_IM,i_EQ}(i_dir,i_floor)

EDPCell = cell(size(EDPMat,2),size(EDPMat,1));
for i_IM = 1:size(EDPCell,1)
    for i_EQ = 1:size(EDPCell,2)
        EDPCell{i_IM,i_EQ} = reshape(EDPMat(i_EQ,i_IM,:,:), ...
            size(EDPMat,3),size(EDPMat,4));
    end
end

end

