
package require starkit

set startup [starkit::startup]

if {$startup ne "sourced"} {
	lappend auto_path $starkit::topdir/lib
}

source [file join $starkit::topdir make.tcl]
eval tclmake $argv



#foreach x [glob -dir [file join $starkit::topdir modules] *.module] {
#    source $x
#}


