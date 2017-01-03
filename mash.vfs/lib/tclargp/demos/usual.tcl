#!/bin/sh
# \
exec tclsh "$0" "$@"

set auto_path [linsert $auto_path 0 ..]

package require argp 0.1

namespace eval demo {

    # first, show all the argument types that exist and how
    #  they are declared (including default value)
    argp::registerArgs process1 {
	{-name   string  ""}
	{-nice   integer 0 }
	{-%cpu   double  0 }
	{-alive  boolean 1 }
    }

    # show how different value ranges can be defined
    argp::registerArgs process2 {
	{-name   string  tclsh {tclsh tcl wish wishx} }
	{-nice   integer 0  { {-20 20} }              }
	{-%cpu   double  0  { {0 100 } }              }
	{-alive  bool    1  }
    }
}

proc demo::process1 { args } {
    # parse
    argp::parseArgs processargs

    # and show the values (given or set by default)
    foreach {k v} [array get processargs] {
	puts "$k $v"
    }
}

proc demo::process2 { args } {
    # parse
    argp::parseArgs processargs

    # and show the values (given or set by default)
    foreach {k v} [array get processargs] {
	puts "$k $v"
    }
}


# this proc will accept about anything
demo::process1 -name explorer.exe -alive false -nice -1000 -%cpu 100 
# well, unless you give wrong types
catch {demo::process1 -alive nope} res
puts $res
# or false argnames
catch {demo::process1 -something wrong} res
puts $res

# this proc checks it's parameters more thoroughly
demo::process2 -name tclsh -alive 1 -nice 20 -%cpu 0.1
# see, doesn't like wrong processnames *grin*
catch {demo::process2 -name explorer.exe} res
puts $res
# or wrong value ranges
catch {demo::process2 -nice 40} res
puts $res


