
package require starkit

set startup [starkit::startup]

if {$startup ne "sourced"} {
	set auto_path [linsert $auto_path 0 $starkit::topdir/lib]      
}

package require mash
package require yaml
package require mustache
package require argp
package require cmdline

set savedDir [pwd]

foreach x [glob -dir [file join $starkit::topdir modules] *.module] {
    source $x
}

set parameters {
    {file.arg "MashFile"    "Which file to execure"}
    {vars.arg ""		        "Variables"}
    {S.arg ""            "Sudo password"}
}

array set arg [cmdline::getoptions argv $parameters]

set vars [dict create]

if {[string length $arg(vars)] > 0} {
	set vars [dict merge $vars [::yaml::yaml2dict -file $arg(vars)]]
}

if {[string length $arg(S)] > 0} {
  dict set vars sudo_password $arg(S)
}

set mashFile [::yaml::yaml2dict -file $arg(file)]
set commandsCount 0
foreach cmds [split $argv " "] {
	set commandsCount [expr { $commandsCount + [llength [dict get $mashFile tasks $cmds cmd]] }]
}

puts "mash 0.1 <markus.marx@marxenter.de>"

set currentStep  0
foreach cmds [split $argv " "] {
  puts "TASK: [dict get $mashFile tasks $cmds name]"
	foreach action [dict get $mashFile tasks $cmds cmd] {
    set cmd [mash::parseCmd $action $vars]
		incr currentStep
    puts "\[ $currentStep / $commandsCount \] $action"
    eval $cmd
	}
}
