# define PUSHOVER LOAD -------------------------------------------------------------

pattern Plain 2 Linear {
    
    load 21 1 0 0;
    load 31 2 0 0;
    load 41 3 0 0;
    
}
set step 1;
set nsteps [expr int(ceil(0.08*11880/$step))];
NonLinearStaticDispNoRecs 1e-4 $step $nsteps 41 1 100 $modelName;