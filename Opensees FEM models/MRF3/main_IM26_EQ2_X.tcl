# Created by Matlab script
set OutputDir "Results/IM 2/EQ2/Dir1";
set filePath1 "../EQ Records/FEMA P-695 far-field ground motions/RSN125_FRIULI.A_A-TMZ000.txt";
set ampl1 79403.781909;
set maxtime 56.390000;
source NXFmodel.tcl;
source Nodemass.tcl;
source Gravity.tcl;
wipeAnalysis;
setRayleigh 0.02 1 2;
DynamicAn $maxtime 0.01 $filePath1 101 1 1e-4 $ampl1 $modelName $OutputDir;
