package require mustache

proc template {src dest} {
	global env
	set fp [open $src r]
	set data [dict create]

	foreach key [array names env] {
    	dict append data ${key} $env($key)
	}

	set fpw [open $dest w]
	puts -nonewline $fpw [::mustache::mustache [read $fp] $data]
	close $fpw
	close $fp	
}

proc substitute {src dest} {
	global srcFile
	global destFile
	set srcFile $src
	set destFile $dest
	uplevel #0 {
		set fpw [open $destFile w]
		set fp [open $srcFile r]
		puts -nonewline $fpw "[subst  -nobackslashes -nocommands [read $fp]]"
		close $fp
		close $fpw
	}
}
