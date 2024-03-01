# define GRAVITY LOAD -------------------------------------------------------------

pattern Plain 1 Linear {
    
    # floor 2~3
    set m [expr 65.63*14.59/6.0/2.0/5.0];
    set G1 [expr -$m*1000.0*9.8];
    for {set ifloor 2}  {$ifloor < 4} {incr ifloor} {
        for {set icol 1}  {$icol < 6} {incr icol} {
            load [expr $ifloor*10+$icol] 0 $G1 0;
        }
    } 
    set m [expr 65.63*14.59/12.0*5.0]; 
    set G1 [expr -$m*1000.0*9.8];
    load 26 0 $G1 0;
    load 36 0 $G1 0;
    
    # roof
    set m [expr 70.90*14.59/6.0/2.0/5.0];
    set G1 [expr -$m*1000.0*9.8];
    for {set ifloor 4}  {$ifloor < 5} {incr ifloor} {
        for {set icol 1}  {$icol < 6} {incr icol} {
            load [expr $ifloor*10+$icol] 0 $G1 0;
        }
    } 
    set m [expr 70.90*14.59/12.0*5.0]; 
    set G1 [expr -$m*1000.0*9.8];
    load 46 0 $G1 0;
}
NonLinearStaticNoRecs 1e-4 0.1 10 100 $modelName
loadConst -time 0.0;