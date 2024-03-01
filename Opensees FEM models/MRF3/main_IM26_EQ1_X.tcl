# Created by Matlab script
set OutputDir "Results/IM 2/EQ1/Dir1";
set filePath1 "../EQ Records/FEMA P-695 far-field ground motions/RSN68_SFERN_PEL090.txt";
set ampl1 110699.887067;
set maxtime 99.440000;
source NXFmodel.tcl;
source Nodemass.tcl;
source Gravity.tcl;
wipeAnalysis;
setRayleigh 0.02 1 2;
DynamicAn $maxtime 0.01 $filePath1 101 1 1e-4 $ampl1 $modelName $OutputDir;
