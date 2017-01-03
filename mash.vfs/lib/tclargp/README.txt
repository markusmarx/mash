
The argp package                                  (c) by Bastien Chevreux


What is this package for?

The argp package allows simple and flexible 
 - using and parsing optional arguments in tcl procs (like arguments
    given to Tk widgets)
 - using and parsing commandline arguments given to a tcl script

so that one doesn't need to write argument parsing and checking
routines in procs. E.g.:

proc someProc { a1 a2 args } {
    argp::parseArgs opts

    puts "The color is $opts(-color)."
    ...
}
someProc $x $y -color red -text "Anything you want" -foo $z

where $x and $y are values to the normal tcl fixed arguments a1 and a2
and the rest are optional arguments. 
The argp package allows implicit checking for argument types and
argument values if needed.


License?

argp falls under the Tcl license. So, it's free (in every respect) to
use, copy, modify etc.

