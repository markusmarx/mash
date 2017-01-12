# $Id: yaap.tcl,v 1.6 1994/12/14 18:11:06 pziobrzy Exp $
# This code is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY.
# No author accepts responsibility to anyone for the consequences of using
# it or for whether it serves any particular purpose or works at all.
# Copyright (c) 1994 Peter Ziobrzynski, pzi@interlog.com

# ALL PRIVATE GLOBAL VARIABLES AND FUNCTIONS ARE NAMED WITH __yaap
# and __Yapp PREFIX RESPECTIVELY.
# Two public functions provided by this module: AParse{}, AUsage{}.

set __yaapDoc {

 Yet Another Argument Parsing utility (YAAP).

 This template based argument parsing utility was originally inspired
 by the X11 Intrinsics XtGetApplicationResources() function.

 (There already is a tcl utility of this sort: topgetopt.tcl used in tkinfo.
 I found it a bit short in functionality for my projects and copied
 the algorithm that I had written long time ago in C for my personal toolbox.)

 The idea is to use a single template consisting of a structured list to:

 - Parse command line arguments.
 - Do necessary conversions (or in Tcl case verification) into the
   user variables.
 - Produce a usage/help message describing command line structure and
   detailed description for all options.

 Since all this is done based on a single data structure (template) all
 changes to the structure of the options are automatically reflected
 in the usage/help information.

 The conversion of the argument values is done by a set of 'converter'
 functions. YAAP provides a standard set of converter functions for the 
 basic set of data types like: integer, string, boolean.
 Users can provide their own converters/parsers for a specialized data types
 like: date, time, float, lists, etc.

 YAAP consists of two public functions: AParse() and AUsage().
 The AParse{argTmpl argvs} takes as its arguments the options template
 'argTmpl' and 'argvs' the list of command line arguments.
 It returns a list of unparsed/unused arguments.
 During the argument parsing AParse() will set indicated user variables
 in the stack frame of the caller (by means of 'upvar').

 The argument template is in the form a list of octets with the following
 items:

 1. Flag string like: -help, --help, -x ; or '-' which indicates
    a "positional" argument not preceded by the flag string.
    Flagged arguments can be provided as a separate words as in '-i 99'
    or in a "sticky" form where argument immediately follows the flag string
    like '-i99'.
    Grouping of flags is not supported in favor of multi character flags.
    (Grouping is meant that '-i -v' can be provided as '-iv')

 2. Indicator of the type or existence of the arguments to follow.
	At present 'y' indicates that the option has an argument; 'n' for
    flags without arguments; 'p' to indicate that the previous template
    octet should be used for all specifications except the flag string. 
    (This is used to provide multiple flag strings for the same options)

 3. Name of the argument converter function.
    Converter must be written according to the standard calling convention:
    The converter takes two arguments: variable name to set, argument string.
    It's duty is to parse the argument string and set the given variable.
    If parsing is ok it should return 1 if not 0. The variable to set must
    be "up-shifted" by two stack frames (upvar 2).
    See bellow _Aint{}, _Abool{},... as examples. The 'ap' test has an
    example of converting a file into the list.

 4. Indicator of whether the flag is required or optional: 'y' means optional
    and 'n' means required.

 5. Name of the user variable that will be used to deposit converted
    flag argument. If the flag does not provide arguments it must be of
    the boolean type (if present the 'true' is assumed).

 6. Default value of the option. If the argument is optional and not provided
    on command line this default value is treated as argument and converted
    using specified converter function. 

 7. Argument name. This string is used in the 'usage' message.
    It is needed only when the option has argument.

 8. Description of the option. It is used in the 'usage' message. 

 The AUsage{} function is used mainly internally to display usage message
 in case of the parsing or conversion error.
 Users can still call it after the AParse{} was called.
 The usage information can also be produced by using of a _Axlp{} converter
 function in one of the template items. For example:

     {-?     n _Axpl y - - - "to see this message"}
     {-h     p - - - - - -}
     {-help  p - - - - - -}
     {--help p - - - - - -}

 will produce help message for a number of styles.

 Also to provide a complete usage message the first element of the template
 list must be in the form of a single line description of the command. 

 An example template for a provided test case follows:
    #!/bin/tclsh

    #Flag   Args Type   Opt  Variable Default Name   Description
    #------------------------------------------------------------------
    set tmpl {
    
	    "Yet another argument parsing (YAAP) utility:"

    { -x    n   _Axpl   y   -       -       -       "to see this message"}
    { --x   p - - - - - - }
    { --h   p - - - - - - }
    { --help   p - - - - - - }

    { -f    y   _Astr   y   fName   file1   file    "a string argument" }
    { --f   p - - - - - - }

    { -v    n   _Abool  y   verb    0       -       "a boolean argument" }
    { --v   p - - - - - - }

    { -i    y   _Aint   n   count   -       count   "an integer argument" }

    { -     n   _Aint   y   count2  0       count2  "a positional argument" }
    { -     n   _Astr   y   fName2  file2   file    "a positional argument" }

    { -     l   _Astr   y   sList   -       list    "required list" }

    }

    set argv [AParse tepl argv]

 The follwing help message will be produced if command is given -x flag:

    usage: ap  [-x] [-f <file>] [-v] -i <count> [<count2>] [<file>] <list>...

    Yet another argument parsing (YAAP) utility:

    -x               - to see this message
     also: --x|--h|--help
    -f <file>        - a string argument (file1)
     also: --f
    -v               - a boolean argument (0)
     also: --v
    -i <count>       - an integer argument
    <count2>         - a positional argument (0)
    <file>           - a positional argument (file2)
    <list>...        - required list


}
# END of __yaapDoc

set __yaapContinue 0
set __yaapTmpl {}
set __yaapDescr {}
set __yaapList 1

proc AParse { optTmpl argvs } {

	global __yaapTmpl
	global __yaapDescr
	global __yaapList

	# Save program description:
	set __yaapDescr [lindex $optTmpl 0]

	# Replace program description with default -x template:
	#set __yaapTmpl \
	#	[lreplace $optTmpl 0 0 {-x n _Axpl y - - help "to see this message"}]
	# ,,, not a good idea - let user decide what is his help flag

	set __yaapTmpl [lreplace $optTmpl 0 0]

	# List of arguments that have been parsed:
	set doneList {}

	#
	# First pass through arguments checking only flagged
	# (with Flag strings $o(flagString) see template) options:
	#

	for {	set i 0; set _arg [lindex $argvs $i]
			set argvsLen [llength $argvs] } \
			{ $i < $argvsLen } \
			{ incr i; set _arg [lindex $argvs $i] } {

		set _argLen [string length $_arg]
		#puts "_arg: $_arg, _argLen: $_argLen"

		foreach l $__yaapTmpl {

			__YaapLoadOpts $l

			#puts "$o(flagString),$o(argType),$o(convFun)"

			if { $o(flagString) == "-" } {
				continue
			}
			set flagStringLen [string length $o(flagString)]

			if { !  [string compare $o(flagString) \
					[string range $_arg 0 [expr $flagStringLen -1]]] } {

				lappend doneList $_arg

				if { $_argLen > $flagStringLen } {
					#
					# Check for "sticky" (: -i99) argument:
					#
					if {  $o(argType) == "y" } {
						#
						# Assign the rest of the argument string as it's value:
						#
						set _arg [string range $_arg $flagStringLen end]

						#
						# Assign sticky $_arg to $o(flagString):
						#
						if { ! [$o(convFun)  $o(varName) $_arg] } {
							__YaapError 0 "bad conversion for: $_arg"  
							continue
						}
						set done($o(varName)) 1
						break
					}

					#
					# Sticky stuff on option without arguments:
					#
					__YaapError 0 "malformed option: $o(flagString)"
				}

				# Non sticky arguments( -i 99 or -i)

				if { $_argLen == $flagStringLen } {
					switch -glob -- $o(argType) {
					[Yy]	{
						#
						# Check for separate (: -i 99) argument:
						# Advance to the next argument and assign
						# it as it's value:
						#

						incr i
						if { $i >= $argvsLen } {
							__YaapError 0 \
								"not enough arguments for: $o(flagString)"
							continue
						}
						set _arg [lindex $argvs $i]

						#
						# Assign separate: $_arg to $o(flagString)
						#
						if { ! [$o(convFun)  $o(varName) $_arg] } {
							__YaapError 0 "bad conversion for: $_arg"  
							continue
						}

						lappend doneList $_arg
						set done($o(varName)) 1
					}
					[Nn]	{
						#
						# Assign single (-i), assume true:
						#
						if { $o(convFun) != "-" } { 
							if { ! [$o(convFun)  $o(varName) $_arg] } {
								__YaapError 0 "bad conversion for: $_arg"  
								continue
							}
						} else {
							# Assume true for non-positional without converter:
							_Abool $o(varName) 1
						}
						set done($o(varName)) 1
					}}
				}
			}
		}
		#puts "done$o(varName): [info exists done$o(varName)]"
		#puts "doneList: $doneList"
	}


	#
	# Remove argvs that have been interpreted so far:
	#
	foreach el $doneList {
		set idx [lsearch $argvs $el]
		set argvs [lreplace $argvs $idx $idx]
	}

	#
	# Pass through options template making sure that all required 
	# and positional options are satisfied.
	# Report missing required options as errors.
	#
	foreach l $__yaapTmpl {

		__YaapLoadOpts $l

		# Check if it was already found:
		if { [ info exists done($o(varName))] } {
			continue
		}

		# Abort on missing non-positional and required:
		if { ! $o(isOpt) && $o(flagString) != "-" } {
			__YaapError 0 "missing required option: $o(flagString)"
		}

		# Break on list:
		if { $o(argType) == "l" } {
			break
		}

		# Try to assign positionals:
		if { $o(flagString) == "-" } {

			# Assign from next available argument:
			if { [llength $argvs] > 0 } {
				set _arg [lindex $argvs 0]
				if { ! [$o(convFun)  $o(varName) $_arg] } {
					__YaapError 0 "bad conversion for: $_arg"
					continue
				}
				# Remove assigned argument:
				set argvs [lreplace $argvs 0 0]
			} else {
				# No more arguments:
				if { $o(isOpt) } {
					# Assign the default:
					if { ! [$o(convFun)  $o(varName) $o(argDef)] } {
						__YaapError 0 "bad conversion for: $o(argDef)"
						continue
					}
				} else {
					__YaapError 0 "not enough arguments for: $o(argNm)"
					continue
				}
			}
		} else {
			# Assign default ($o(argDef)) for missing optional non-positionals:
			if { $o(convFun) != "-" } { 
				if { ! [$o(convFun) $o(varName) $o(argDef)] } {
					__YaapError 0 "bad conversion for: $o(argDef)"
					continue
				}
			} else {
				# Assume false for non-positional without converter:
				_Abool $o(varName) 0
			}
		}
	}

	# Check the remainder argvs:
	if { [llength $argvs] == 0 } {
		if { ! $__yaapList } {
			__YaapError 0 "missing required list <...>"
		}
	}

	return $argvs
}

#
# Format a usage message based on the argument template:
#
proc AUsage {} {
	global argv0
	global __yaapTmpl
	global __yaapDescr
	global __yaapContinue

	set cmdLine "usage: $argv0 "
	set argLegend {}

	foreach l $__yaapTmpl {

		__YaapLoadOpts $l

		# Assign brackets for formating:
		__YaapFormat $o(isOpt)

		if { $optRepeat } {
			if { $__yaapContinue } {
				lappend argLegend [format "|%s" $o(flagString)]
			} else {
				lappend argLegend [format " also: %s" $o(flagString)]
			}
			set __yaapContinue 1
			continue
		} else {
			if { $__yaapContinue } {
				lappend argLegend "\n"
			}
			set __yaapContinue 0
		}

		if { $o(flagString) != "-" } {
			# Handle non-positionals (-i 99, -i99):

			switch -glob -- $o(argType) {
			[Yy] 	{
				set cmdLine "$cmdLine $bL$o(flagString) <$o(argNm)>$bR"
				set col1 [format "%s <%-s>" $o(flagString) $o(argNm)]
			}
			[Nn]	{
				set cmdLine "$cmdLine $bL$o(flagString)$bR"
				set col1 $o(flagString)
			}}

		} else {
			# Positinals ($o(flagString) -):

			set listType ""
			if { $optList } {
				set listType "..."
			}

			set cmdLine "$cmdLine $bL<$o(argNm)>$listType$bR"
			set col1 [format "<%s>%s" $o(argNm) $listType]
		}

		# Format legend line:
		if { $o(argDef) != "-" } {
			lappend argLegend \
				[format "%-16s - %s (%s)\n" $col1 $o(argDesc) $o(argDef)]
		} else {
			lappend argLegend [format "%-16s - %s\n" $col1 $o(argDesc)]
		}
	}

	# Print legend:
	puts "$cmdLine\n"
	puts "$__yaapDescr\n"
	foreach _l $argLegend {
		puts -nonewline $_l
	}
    puts ""
}

proc __YaapLoadOpts {line} {
		global __yaapPrevOpt
		global __yaapList

		upvar 1 o o
		upvar 1 optRepeat optRepeat
		upvar 1 optList optList

		set optRepeat 0
		set optList 0

		set o(flagString) [lindex $line 0]

		switch -glob -- [lindex $line 1] {
		[Pp]	{
			if { [lindex $__yaapPrevOpt 0] == "-" } {
				__YaapError 1 "can't continue positional option"
			}
			set line $__yaapPrevOpt
			set optRepeat 1

		}
		[Ll]	{
			set __yaapList [string match {[Yy1]} [lindex $line 3]]
			set optList 1
		}
		[NnYy] {}

		default {
				__YaapError 1 \
					[format "unknown argType value: %s" [lindex $line 1]]
		}}

		# Save current record so it can be used of 'p' argType:
		set __yaapPrevOpt $line

		set o(argType) [lindex $line 1]
		set o(convFun) [lindex $line 2]
		set o(isOpt) [string match {[Yy1]} [lindex $line 3]]
		set o(varName) [lindex $line 4]
		set o(argDef) [lindex $line 5]
		set o(argNm) [lindex $line 6]
		set o(argDesc) [lindex $line 7]
}

proc __YaapFormat { opt } { 
	upvar 1 bL bL
	upvar 1 bR bR
	set bL ""
	set bR ""
	if { $opt } {
		set bL "\["
		set bR "\]"
	}
}

proc __YaapError { level str } {
	global argv0

	puts "$argv0 Error: $str"
	if { $level == 0 } { 
		AUsage
	}
	exit 1
}


#
# Argument conversion/parsing functions:
#

# Parse help argument:
proc _Axpl {varName arg} {
	if { $arg != "-" } {
		AUsage
		exit 0
	}
	return 1
}

# Parse string argument:
proc _Astr {varName arg} {
	upvar 2 $varName pVar

	set pVar $arg 
	return 1
}

# Parse integer argument:
proc _Aint {varName arg} {
	upvar 2 $varName pVar

	switch -regexp -- $arg {
	[0-9]+	{ set pVar $arg; return 1 }
	default { return 0 }
	}
}

# Parse boolean argument:
proc _Abool {varName arg} {
	upvar 2 $varName pVar

	switch -regexp -- $arg {
	[yYtT1]	{ set pVar 1; return 1 }
	[nNfF0]	{ set pVar 0; return 1 }
	}

	return 0
}

# ex:set sw=4 ts=4: