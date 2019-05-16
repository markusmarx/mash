

proc is_empty {string} {
    expr {![binary scan $string c c]}
}

proc not_empty {string} {
    expr {![is_empty $string]}
}

proc show {filename} {
	global showfile
	set showfile $filename
	uplevel #0 {set fp [open $showfile r]; puts "[subst  -nobackslashes -nocommands [read $fp]]"; close $fp}
}

proc cmd {args} {
	set execute [join [linsert $args 0 "exec >&@stdout <@stdin"] " "]
	set errorcode [catch {uplevel #0 "$execute"} msg]
    if $errorcode {
		# There was a return error code
		if { $errorcode == 3 } {
		    # The error was from a break, so stop processing
		    # this command
		    break
		} else {
		    _error $msg
		}
    }
}