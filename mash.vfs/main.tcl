
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
	set mash::Variables [dict merge $vars [::yaml::yaml2dict -file $arg(vars)]]
}

if {[string length $arg(S)] > 0} {
  dict set mash::Variables sudo_password $arg(S)
}

source [file join $starkit::topdir rule.def.tcl]

source $arg(file)

puts "mash 0.3 <markus.marx@marxenter.de>"

set currentStep  0

set cmds [split $argv " "]

set rules [mash::rule get $cmds]

foreach rule $rules {
  foreach {modName modVal} [$rule cget -modules] {
    $modName "$modVal"
  }

}