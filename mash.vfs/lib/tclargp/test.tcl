#!/bin/sh
# \
exec tclsh "$0" "$@"

set auto_path [linsert $auto_path 0 .]

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
demo::newCity "New York"
demo::newCity "Washington"
demo::newCity "Los Angeles"
argp::setArgDefaults demo::newCity {-nationality french}
demo::newCity "Paris" 
demo::newCity "Marseilles" 
demo::newCity "Strasbourg"
