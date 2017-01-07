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

}

##
#	mash::task
##
proc mash::task {args} {
	set task [TASK #auto]

	set name ""
	if {[expr {[llength $args] % 2}] == 0} {
		set args [lassign $args name]
	}
	$task.name = $name
	$task.modules = [lassign $args attrs]
	$task.attrs = $attrs
	
	lappend mash::allTasks $task
}
