
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

foreach x [glob -dir [file join $starkit::topdir rules] *.rule.tcl] {
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
	set mash::allVars [dict merge $vars [::yaml::yaml2dict -file $arg(vars)]]
}

if {[string length $arg(S)] > 0} {
  dict set mash::allVars sudo_password $arg(S)
}

proc task args {
  mash::task $args
}

source $arg(file)

puts "mash 0.2 <markus.marx@marxenter.de>"

set currentStep  0

set cmds [split $argv " "]

set tasks [mash::getTask $cmds]

foreach task $tasks {
  
  foreach {modName modVal} [$task cget -modules] {
    $modName "$modVal"
  }

}