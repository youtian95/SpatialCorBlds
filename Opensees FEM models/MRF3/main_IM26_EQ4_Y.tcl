# Created by Matlab script
set OutputDir "Results/IM 2/EQ4/Dir2";
set filePath1 "../EQ Records/FEMA P-695 far-field ground motions/RSN174_IMPVALL.H_H-E11230.txt";
set ampl1 77810.489442;
set maxtime 59.460000;
source NXFmodel.tcl;
source Nodemass.tcl;
source Gravity.tcl;
wipeAnalysis;
setRayleigh 0.02 1 2;
DynamicAn $maxtime 0.01 $filePath1 101 1 1e-4 $ampl1 $modelName $OutputDir;
