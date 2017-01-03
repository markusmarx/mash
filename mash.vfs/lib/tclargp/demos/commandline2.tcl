#!/bin/sh
# \
exec tclsh "$0" "$@"

# This demo shows how to parse commandline arguments with argp
#  (another possibility)

set auto_path [linsert $auto_path 0 ..]
package require argp 0.1

namespace eval myprog {
    argp::registerArgs myparse {
	{-name   string  tclsh {tclsh tcl wish wishx}                }
	{-number integer 10    { { - -20 } { 5 100 } { 200 +} }      }
	{-%cpu   double  90    { 50.0 50.1 50.3  { 90 100 } }        }         
	{-alive  boolean 1     { 1 }                                 }
    }
}

proc myprog::myparse {args} {
    # parse
    argp::parseArgs opts

    # and show the values (given or set by default)
    foreach {k v} [array get opts] {
	puts "option $k has value $v"
    }
}

eval myprog::myparse $argv
















