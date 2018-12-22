
package require starkit

set startup [starkit::startup]

if {$startup ne "sourced"} {
	lappend auto_path $starkit::topdir/lib
}

#######################################################################
#### tclmake
# The main procedure. This procedure creates an interpreter
# within which the make for the current directory can run, and
# then loads the package into that directory and so on. The first
# argument is the name of the directory to run in.
# 
proc tclmake {args} {
    global env

    # Create a new interpreter
    set interp [interp create]

    # Give the interpreter access to the auto_mkindex function
    # in _this_ interpreter. This is so the itcl version
    # runs (if we are running in itclsh).
    $interp alias auto_mkindex auto_mkindex

    # Execute the main procedure.
    set script {
		lappend auto_path $starkit::topdir/lib
		package require tclmake

		# Set variables and call the _tclmake procedure
		set _vars(MAKE) "mash"
		set _vars(MAKEDIR) [pwd]
		set _vars(MAKEVARS) ""
		set _vars(MFLAGS) ""
		set _topdir $starkit::topdir
		eval _tclmake $args
    }

    set script [subst -nocommands $script]

    $interp eval $script
}

eval tclmake $argv


