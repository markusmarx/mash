package provide mash 0.1

namespace eval mash {

	proc parseCmd {commandStr varsDict} {
		regexp -indices {(^[^\s]*)} $commandStr location
		set command [string range $commandStr [lindex $location 0] [lindex $location 1]]
		set arguments [string range $commandStr [expr {[lindex $location 1] + 1}] end]

		set splitArgs [split $arguments =]
		set argumentStr ""
		foreach {name value} $splitArgs {
		    append argumentStr [string trim $name] " " [string trim $value] " "
		}

		if {[info exists varsDict]} {
			set argumentStr [::mustache::mustache $argumentStr $varsDict]
		}

		return [string trim "$command $argumentStr"]
	}
}