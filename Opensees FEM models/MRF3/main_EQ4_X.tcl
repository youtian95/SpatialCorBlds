# Created by Matlab script
set OutputDir "Scenario Chi-Chi19990920/EQ4/Dir1";
set filePath1 "../EQ Records/Chi-Chi19990920/RSN1193_CHICHI_CHY024-E.txt";
set ampl1 9810.000000;
set maxtime 109.995000;
source NXFmodel.tcl;
source Nodemass.tcl;
source Gravity.tcl;
wipeAnalysis;
setRayleigh 0.02 1 2;
DynamicAn $maxtime 0.01 $filePath1 101 1 1e-4 $ampl1 $modelName $OutputDir;
