#!/bin/bash
# Builds dist files from the current working branch.
#
# You can specify the version as first argument:
#   ./build.sh 1234
#
# Exception: if the argument is "svg", this script 
# will only generate the svg file and omit the rest.


##########
# Configuration

# Custom path to gnuclad (leave empty if you already installed it in your PATH)
GC=/home/bryonak/c/gnuclad/bryonak/src/gnuclad

# The basename of the .csv and .conf file
PROJNAME='gldt'

# Which files to include into the archive
DISTFILES='gldt.csv gldt.conf ToDo ChangeLog README LICENSE images build.sh'

#
##########
# Code starts here

VERS=$1

# Check if which is present. Otherwise abort.
type -P which &>/dev/null || { echo "which not found: aborting" >&2; exit 1;}

# Check if custom path is valid and nonempty. Otherwise try to get it via which.
type -P $GC &>/dev/null && [ -n "$GC" ] ||
	{ [ -n "$GC" ] && echo "No gnuclad in custom path: using PATH (which)";
	GC=$(which gnuclad); }

# If GC is present (nonempty), check for svg shortcut. Otherwise abort.
[ -n "$GC" ] || { echo "gnuclad not found: aborting" >&2; exit 1; }
[ "$VERS" == "svg" ] && { $GC $PROJNAME.csv svg $PROJNAME.conf; exit 0; }

# Run gnuclad and abort on error.
CHECK=`$GC $PROJNAME.csv $PROJNAME$VERS.svg $PROJNAME.conf`
echo -e "$CHECK"
[[ `echo -e "$CHECK" | grep "^Error:"` ]] && exit 1;

# Check for Inkscape and run it if present. Otherwise ignore.
INK=$(which inkscape)
[ -n "$INK" ] || echo "Inkscape not found: will not generate png"
[ -n "$INK" ] && $INK $PROJNAME$VERS.svg -D --export-png=$PROJNAME$VERS.png

# Packaging
echo "Packaging..."
type -P tar &>/dev/null || { echo "tar not found: aborting" >&2; exit 1;}
type -P bzip2 &>/dev/null || { echo "bzip2 not found: aborting" >&2; exit 1;}

tar -c $DISTFILES > $PROJNAME$VERS.tar
bzip2 $PROJNAME$VERS.tar

BDIR="DIST_$PROJNAME$VERS"
mkdir -p $BDIR
mv $PROJNAME$VERS.svg $BDIR
[ -n "$INK" ] && mv $PROJNAME$VERS.png $BDIR
mv $PROJNAME$VERS.tar.bz2 $BDIR

echo "Distribution can be found in $BDIR"

