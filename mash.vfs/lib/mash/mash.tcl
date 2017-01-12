package require argp
package require struct


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


package provide mash 0.1
