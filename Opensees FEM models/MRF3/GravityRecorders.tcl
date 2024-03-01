# $OutputDir, $patternStart


recorder Node -file $OutputDir/AxialForce11.out -time -node 11  -dof 2 reaction;
recorder Node -file $OutputDir/AxialForce12.out -time -node 12  -dof 2 reaction;
recorder Node -file $OutputDir/AxialForce13.out -time -node 13  -dof 2 reaction;
recorder Node -file $OutputDir/AxialForce14.out -time -node 14  -dof 2 reaction;
recorder Node -file $OutputDir/AxialForce15.out -time -node 15  -dof 2 reaction;
recorder Node -file $OutputDir/AxialForce16.out -time -node 16  -dof 2 reaction;

# test
#recorder Node -file $OutputDir/Acc0X.out -timeSeries [expr $patternStart+1] -time -node 5 -dof 1 accel;
#recorder Node -file $OutputDir/Acc0Y.out -timeSeries [expr $patternStart+2] -time -node 5 -dof 2 accel;
#recorder Node -file $OutputDir/Vel0X.out -timeSeries [expr $patternStart+1] -time -node 5 -dof 1 vel;
#recorder Node -file $OutputDir/Vel0Y.out -timeSeries [expr $patternStart+2] -time -node 5 -dof 2 vel;
#recorder Node -file $OutputDir/Acc1X_relative.out -time -node 295 -dof 1 accel;
#recorder Node -file $OutputDir/Acc1Y_relative.out -time -node 295 -dof 2 accel;
#recorder Node -file $OutputDir/Vel1X_relative.out -time -node 295 -dof 1 vel;
#recorder Node -file $OutputDir/Vel1Y_relative.out -time -node 295 -dof 2 vel;