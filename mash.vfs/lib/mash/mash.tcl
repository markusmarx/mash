package require argp
package require struct
package require fileutil


namespace eval ::mash {

	struct::record define RULE {
		name
		attrs
		modules
	}

	set Rules {}

	set Variables [dict create]

	##
    ##  These are the possible sub commands
    ##
    variable commands
    set commands [list add get]
}

#------------------------------------------------------------
# ::mash::rule --
#
#    Used to process rule
#
# Arguments:
#
#    cmd_ - commands add, get
#    args - command arguments
#
# Results:
#   
#------------------------------------------------------------
#
proc mash::rule {cmd_ args} {
	variable commands

    if {[lsearch $commands $cmd_] < 0} {
        error "Sub command \"$cmd_\" is not recognized. Must be [join $commands ,]"
    }

    set cmd_ [string totitle "$cmd_"]
    return [uplevel 1 ::mash::rule_${cmd_} $args]
}


#------------------------------------------------------------
# ::mash::rule_Add --
#
#	Used to add a rule
#
# Arguments:
#    
#	args - rule definition	
#
# Results:
#   
#------------------------------------------------------------
#
proc mash::rule_Add {args} {
	set task [RULE #auto]
	if {[llength $args] == 1} {
		set args [lindex $args 0]
	} 
	set name "default"
	if {[expr {[llength $args] % 2}] == 0} {
		set args [lassign $args name]
	}
	$task.name = $name
	$task.modules = [lassign $args attrs]
	$task.attrs = $attrs

	lappend mash::Rules $task
}


#------------------------------------------------------------
# ::mash::rule_Get --
#
#	get rule by name
#
# Arguments:
#    
#	name - rule name
#
# Results:
#   
#------------------------------------------------------------
#
proc mash::rule_Get {name} {
	foreach taskName $name {
		set tasks($taskName) {}
	}

	foreach task $mash::Rules {
		set idx [lsearch $name [$task cget -name]]
		if { $idx >= 0 } {
			lappend tasks([$task cget -name]) $task
		}	
	}
	set flattenTasks {}

	foreach taskName $name {
		lappend flattenTasks $tasks($taskName)
	}
	return [::struct::list flatten $flattenTasks]
}


#------------------------------------------------------------
# ::mash::errorMsg --
#
#	puts error message
#
# Arguments:
#    
#	msg - message
#
# Results:
#   
#------------------------------------------------------------
#
proc mash::errorMsg {msg} {
	puts "mash: ***$msg Stop."
}


#------------------------------------------------------------
# ::mash::findMashfiles --
#
#	find files by pattern
#
# Arguments:
#    
#	basePath - base search path
#   patter   - glob pattern
#
# Results:
#   
#------------------------------------------------------------
#
proc mash::findMashfiles {basePath pattern} {
	proc match {name} {
		upvar pattern pattern
		return [string match $pattern $name]
	}
	return [file join $basePath "Mashfile"]
}


#------------------------------------------------------------
# ::mash::findMashfiles --
#
#	find files by pattern
#
# Arguments:
#    
#	basePath - base search path
#   patter   - glob pattern
#
# Results:
#   
#------------------------------------------------------------
#
proc mash::pathSort {pathlist} {
	proc filepathsort {item1 item2} {
		set l1 [llength [file split $item1]]
		set l2 [llength [file split $item2]]
		return [expr {$l1-$l2}]
	}
	return [lsort -command filepathsort $pathlist]
}

proc mash::load {basePath pattern} {
	set mashFiles [mash::pathSort [mash::findMashfiles $basePath $pattern]]
	if {[llength $mashFiles] == 0} {
  		mash::errorMsg "No Mashfile for pattern \"$pattern\" found."
  		exit 1;
	}
	foreach m $mashFiles {
		uplevel source $m
	}
}

package provide mash 0.1
