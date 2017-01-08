package provide mash 0.1
package require argp
package require struct


namespace eval mash {

	struct::record define TASK {
		name
		attrs
		modules
	}

	set allTasks {}

	set allVars [dict create]
}

proc mash::getTask {name} {
	foreach taskName $name {
		set tasks($taskName) {}
	}

	foreach task $mash::allTasks {
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

##
#	mash::task
##
proc mash::task {args} {
	set task [TASK #auto]
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

	lappend mash::allTasks $task
}
