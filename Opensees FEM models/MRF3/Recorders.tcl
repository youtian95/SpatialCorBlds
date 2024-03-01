# $OutputDir, $patternStart

recorder EnvelopeNode -file $OutputDir/Acc0.out -time -timeSeries [expr $patternStart+1] -node 11   -dof 1 accel;
recorder EnvelopeNode -file $OutputDir/Acc1.out -time -timeSeries [expr $patternStart+1] -node 21   -dof 1 accel;
recorder EnvelopeNode -file $OutputDir/Acc2.out -time -timeSeries [expr $patternStart+1] -node 31   -dof 1 accel;
recorder EnvelopeNode -file $OutputDir/Acc3.out -time -timeSeries [expr $patternStart+1] -node 41   -dof 1 accel;

recorder EnvelopeNode -file $OutputDir/Vel0.out -time -timeSeries [expr $patternStart+1] -node 11   -dof 1 vel;
recorder EnvelopeNode -file $OutputDir/Vel1.out -time -timeSeries [expr $patternStart+1] -node 21   -dof 1 vel;
recorder EnvelopeNode -file $OutputDir/Vel2.out -time -timeSeries [expr $patternStart+1] -node 31   -dof 1 vel;
recorder EnvelopeNode -file $OutputDir/Vel3.out -time -timeSeries [expr $patternStart+1] -node 41   -dof 1 vel;

recorder Drift -file $OutputDir/Drift1.out -time -iNode 11 -jNode 21 -dof 1 -perpDirn 2;
recorder Drift -file $OutputDir/Drift2.out -time -iNode 21 -jNode 31 -dof 1 -perpDirn 2;
recorder Drift -file $OutputDir/Drift3.out -time -iNode 31 -jNode 41 -dof 1 -perpDirn 2;

# test
#recorder Node -file $OutputDir/Acc0X.out -timeSeries [expr $patternStart+1] -time -node 5 -dof 1 accel;
#recorder Node -file $OutputDir/Acc0Y.out -timeSeries [expr $patternStart+2] -time -node 5 -dof 2 accel;
#recorder Node -file $OutputDir/Vel0X.out -timeSeries [expr $patternStart+1] -time -node 5 -dof 1 vel;
#recorder Node -file $OutputDir/Vel0Y.out -timeSeries [expr $patternStart+2] -time -node 5 -dof 2 vel;
#recorder Node -file $OutputDir/Acc1X_relative.out -time -node 295 -dof 1 accel;
#recorder Node -file $OutputDir/Acc1Y_relative.out -time -node 295 -dof 2 accel;
#recorder Node -file $OutputDir/Vel1X_relative.out -time -node 295 -dof 1 vel;
#recorder Node -file $OutputDir/Vel1Y_relative.out -time -node 295 -dof 2 vel;