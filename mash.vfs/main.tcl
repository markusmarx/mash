
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

source [file join $starkit::topdir yapp.tcl]

set savedDir [pwd]

foreach x [glob -dir [file join $starkit::topdir modules] *.module] {
    source $x
}

foreach x [glob -dir [file join $starkit::topdir rules] *.rule.tcl] {
    source $x
}

set tmpl {
    "METASHELL v.0.4:"

    { -h        n   _Axpl   y   -         -          -               "to see this message"}
    { --help    p - - - - - - }

    { -p        y   _Astr   y   fName     Mashfile   "file pattern"  "find pattern for mashfiles e.g. Mashfile" }
    { --pattern p - - - - - - }

    { -k        y   _Astr   y   sPassword -          -               "sudo password" }
    { --sudo    p - - - - - - }

    { -         l   _Astr   y   sRules    default    "rule list"      "Rules to processed." }
    }

set sRules [AParse $tmpl $argv]

set vars [dict create]

#if {[string length $arg(vars)] > 0} {
#	set mash::Variables [dict merge $vars [::yaml::yaml2dict -file $arg(vars)]]
#}

if {[info exist sPassword]} {
  dict set mash::Variables sudo_password $sPassword
}

source [file join $starkit::topdir rule.def.tcl]

mash::load [pwd] $fName

set currentStep  0

if {$sRules == ""} {
  mash::errorMsg "No rule given."
  exit 1
}

set rules [mash::rule get $sRules]

if {[llength $rules] == 0} {
  mash::errorMsg "No rule found for \"$sRules\""
  exit 1
}

foreach rule $rules {
  foreach {modName modVal} [$rule cget -modules] {
    $modName "$modVal"
  }

}
exit 0;
