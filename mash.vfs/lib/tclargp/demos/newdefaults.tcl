#!/bin/sh
# \
exec tclsh "$0" "$@"

# This demo shows how to change default values
#  (two possibilities)

set auto_path [linsert $auto_path 0 ..]

package require argp 0.1

namespace eval demo {
    argp::registerArgs newCity {
	{-numcitizen integer 0 }
	{-nationality string american }
    }
}

proc demo::newCity { name args } {
    argp::parseArgs cityargs
    
    puts -nonewline "Creating $name, which has $cityargs(-numcitizen) "
    puts "citizen and is $cityargs(-nationality)."
}

proc demo::changeDefaults {} {
    argp::setArgDefaults newCity {-nationality german}
}

demo::newCity "New York"
demo::newCity "Washington"
demo::newCity "Los Angeles"

argp::setArgDefaults demo::newCity {-nationality french -numcitizen 10}

demo::newCity "Paris" 
demo::newCity "Marseilles" 
demo::newCity "Strasbourg"

demo::changeDefaults

demo::newCity "Berlin" 
demo::newCity "München" 
demo::newCity "Köln"

