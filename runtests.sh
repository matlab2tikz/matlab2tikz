#!/usr/bin/env bash
#
# Test script runner for MATLAB2TIKZ continuous integration
#
# You can influence the execution by passing one or two parameters
# to this function, as
#
#     ./runtests.sh RUNNER SWITCHES
#
# Arguments:
#   - RUNNER: (path of) the binary you want to use to execute the tests
#         default value: "octave"
#   - SWITCHES: switches you want to pass to the executable
#         default value: * "-nodesktop -r" if runner contains "matlab"
#                        * "--no-gui --eval" if runner contains "octave" and otherwise
#

# Used resources:
#  - http://askubuntu.com/questions/299710/how-to-determine-if-a-string-is-a-substring-of-another-in-bash
#  - http://www.thegeekstuff.com/2010/07/bash-case-statement/
#  - http://stackoverflow.com/questions/229551/string-contains-in-bash

## Handle Runner and Switches variables
Runner=$1
Switches=$2
if [ -z "$Runner" ] ; then
	Runner="octave"
fi
if [ -z "$Switches" ] ; then
	case "$Runner" in
		*matlab* )
			Switches="-nodesktop -r"
			;;

		*octave* )
			Switches="--no-gui --eval"
			;;

		* )
			# Fall back to Octave switches
			Switches="--no-gui --eval"
			;;
    esac
fi

## Make sure the different harnesses know the intent
CONTINUOUS_INTEGRATION=true
CI=true

## Actually run the test suite
cd test
TESTDIR=`pwd`
# also CD in MATLAB/Octave to make sure that startup files
# cannot play any role in setting the path
${Runner} ${Switches} "cd('${TESTDIR}'); runMatlab2TikzTests"
cd ..

## Post-processing

# convert MD report into HTML using pandoc if available
MDFILE="test/results.test.md"
if [ ! -z `which pandoc` ]; then
	if [ -f $MDFILE ]; then
	    HTMLFILE=${MDFILE/md/html}
	    # replace the emoji while we're at it
	    pandoc -f markdown -t html $MDFILE -o $HTMLFILE
	    sed -i -- 's/:heavy_exclamation_mark:/❗️/g' $HTMLFILE
	    sed -i -- 's/:white_check_mark:/✅/g' $HTMLFILE
	    sed -i -- 's/:grey_question:/❔/g' $HTMLFILE
	fi
fi

