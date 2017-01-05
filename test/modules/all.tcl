package require tcltest

namespace import ::tcltest::*

configure -tmpdir [file join [file dirname [info script]]] \
		  -testdir [file join [file dirname [info script]]] \
		  -singleproc true

runAllTests