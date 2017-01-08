package require mustache
package require yaml

##
#	parseCmd
##
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

proc trim-indentation {msg} {
    set msgLines [split $msg \n]
    if {[lindex $msgLines 0] eq {}} {
        shift msgLines
    }

    set firstLine [lindex $msgLines 0]

    set indent [
        expr {
            [string length $firstLine] -
            [string length [string trimleft $firstLine]]
        }
    ]

    return [
        join [
            struct::list mapfor x $msgLines {string range $x $indent end}
        ] \n
    ]
}


##
#	cmd
##
proc cmd {args} {
	lassign $args commands
	#delete empty lines
	regsub -all {^(?:[\t ]*(?:\r?\n|\r))+} $commands "" commands
	set cmdDict [yaml::yaml2dict [trim-indentation $commands]]
	
	set result 0
	foreach cmdItem $cmdDict {
		if {$cmdItem != ""} {
			puts $cmdItem
			if [catch {eval "[parseCmd $cmdItem $mash::allVars]"}] {
				set result 1
			}
		}
	}
	return $result
}