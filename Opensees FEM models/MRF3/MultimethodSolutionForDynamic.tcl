# need: $TmaxAnalysis; $DtAnalysis; 

set TolDynamic 1.0e-4 ;
set testTypeDynamic EnergyIncr  ;
set maxNumIterDynamic 20 ;
set algorithmTypeDynamic NewtonLineSearch;

algorithm $algorithmTypeDynamic
test $testTypeDynamic  $TolDynamic $maxNumIterDynamic  0;

set okLastStep 0; set ok0 0; set ok 0;
set tempDt [expr $DtAnalysis];
set decreaseN  0;  set maxDecreaseTimes 6;
set controlTime [getTime];
while {$decreaseN <= $maxDecreaseTimes && $controlTime < $TmaxAnalysis} {
    while {$controlTime < $TmaxAnalysis && $ok == 0 } {
        set controlTime [getTime]
        set ok [analyze 1 $tempDt]
        #if {$ok != 0} {
        #    puts "Trying Newton with Initial Tangent .."
        #    algorithm Newton -initial
        #    set ok [analyze 1 $tempDt];
        #    #algorithm NewtonLineSearch .8;
        #    algorithm $algorithmTypeDynamic
        #};
        #if {$ok != 0} {
        #    puts "Trying NewtonWithLineSearch .."
        #    algorithm NewtonLineSearch .8
        #    set ok [analyze 1 $tempDt]
        #    algorithm $algorithmTypeDynamic
        #};
        set okLastStep $ok0 ; # last step
        set ok0  $ok ;   # now step
        # if success
        if {$ok0 == 0} {
            set t [getTime];
            #puts "t: $t";
            set decreaseN  0 ;
        };
        # increase dt
        if {$ok0 == 0 && $okLastStep == 0} {
            set tempDt  [expr min([expr $tempDt*2],$DtAnalysis)];
        }
    };     
    # decrease dt
    if {$ok0 != 0} {
        set tempDt  [expr max([expr $tempDt/10],1.0e-16)];
        set decreaseN  [expr $decreaseN+1] ;
        puts "dt: $tempDt;   u: $decreaseN"
        set ok 0;
    };
};