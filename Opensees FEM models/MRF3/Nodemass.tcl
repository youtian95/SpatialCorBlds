# 1 kips-sec2/ft = 14.59 ton

# floor 2~3
set m [expr 65.63*14.59/6.0/2.0/5.0];
for {set ifloor 2}  {$ifloor < 4} {incr ifloor} {
    for {set icol 1}  {$icol < 6} {incr icol} {
        mass [expr $ifloor*10+$icol] $m 0 0;  
    }
} 
set m [expr 65.63*14.59/12.0*5.0]; 
mass 26 $m 0 0;
mass 36 $m 0 0;

# roof
set m [expr 70.90*14.59/6.0/2.0/5.0];
for {set ifloor 4}  {$ifloor < 5} {incr ifloor} {
    for {set icol 1}  {$icol < 6} {incr icol} {
        mass [expr $ifloor*10+$icol] $m 0 0;  
    }
} 
set m [expr 70.90*14.59/12.0*5.0]; 
mass 46 $m 0 0;
