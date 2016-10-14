#!/bin/bash

###
#
# versionerJ 0.03
#
###

### Static Params ###
	files=(
		'src/js/config/config.js||version:'
		'config.xml|pokedesk|version='
		)
		
### Funcs ###

	function usage {
		echo "usage: `basename $0` version-number [root path]"
		exit 0
	}

	function errExit {
		#$1 str
		echo "`basename $0` error: $1"
		exit 1
	}

### Preset ###
	[ $# -lt 1 ] && [ $# -gt 2 ] && usage
	rootPath=''
	if [ $# == 2 ]; then
		[ -d "$2" ] || errExit "Root path not found '$2'"
		rootPath="$2/"
	fi

### Checkup ###

	for item in ${files[*]}; do
		elmt=($(echo $item | sed 's/|/ /g'))
		filename="${rootPath}${elmt[0]}"
		selector=${elmt[1]}
		needdle=${elmt[2]}
 		[ -f "$filename" ] || errExit "$filename not found!"
 		if [ ! $selector ]; then	
 			[ "$(cat "$filename" | sed /$needdle/!d)" ] || errExit "Version tag not found in '$filename'"
 		else		
 			[ "$(cat "$filename" | sed -e /$selector/!d -e /$needdle/!d)" ] || errExit "Version tag not found in '$filename'"
 		fi
	done

# ### Main ###

	for item in ${files[*]}; do
		elmt=($(echo $item | sed 's/|/ /g'))
		filename="${rootPath}${elmt[0]}"
		selector=${elmt[1]}
		needdle=${elmt[2]}
		# work around to avoid EOF ending a line without CR
			cat "$filename" | sed 's/+/+/' >"${filename}_tmp"
			mv -f "${filename}_tmp" "${filename}"
		#
		linesamt0=$(cat "$filename" | wc -l | sed 's/ //g')
		cat "$filename" | sed "s/\(${selector}.*${needdle}[ ]\{0,10\}['\"]\)\(.*\)\(['\"]\)/\1${1}\3/" >"${filename}_tmp"
		linesamt1=$(cat "${filename}_tmp" | wc -l | sed 's/ //g')
		[ $linesamt0 == $linesamt1 ] || errExit "Bug in replacement. Lines amount doesn't match."
		mv -f "${filename}_tmp" "${filename}"
	done
	
