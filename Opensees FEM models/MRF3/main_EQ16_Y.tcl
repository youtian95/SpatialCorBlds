# Created by Matlab script
set OutputDir "Scenario Chi-Chi19990920/EQ16/Dir2";
set filePath1 "../EQ Records/Chi-Chi19990920/RSN1227_CHICHI_CHY074-N.txt";
set ampl1 9810.000000;
set maxtime 109.995000;
source NXFmodel.tcl;
source Nodemass.tcl;
source Gravity.tcl;
wipeAnalysis;
setRayleigh 0.02 1 2;
DynamicAn $maxtime 0.01 $filePath1 101 1 1e-4 $ampl1 $modelName $OutputDir;
