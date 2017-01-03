#!/bin/sh
# \
exec tclsh "$0" "$@"

# This demo shows how to parse commandline arguments with argp
#  (a possibility)

set auto_path [linsert $auto_path 0 ..]

package require argp 0.1

namespace eval demo {
    argp::registerArgs newCity {
	{-numcitizen integer 0 }
	{-nationality string american }
	{-surface double 1.0 }
    }

    # make sure that -surface and -numcitizen are always given
    argp::setArgsNeeded newCity {-surface -numcitizen}
}

proc demo::newCity { name args } {
    argp::parseArgs cityargs
    
    puts -nonewline "Creating $name, which has $cityargs(-numcitizen) "
    puts "citizen and is $cityargs(-nationality)."
    puts "The city covers a surface of $cityargs(-surface) km^2."
}

catch {demo::newCity "New York"} res
puts $res
catch {demo::newCity "Paris" -numcitizen 5000000 -nationality french} res
puts $res
demo::newCity "Berlin" -numcitizen 3500000 -surface 147 -nationality german
















