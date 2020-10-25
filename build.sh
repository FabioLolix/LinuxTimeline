#!/bin/sh
#
# Linux Timeline build script
#
# Specify project name (default: ldt)
PROJNAME="${PROJNAME:=ldt}"

msg() {
    printf "==> %s%s\n" "$2" "$1"
}

die() {
    msg "$1" "ERROR: "
    exit 1
}

warn() {
    msg "$1" "WARNING: "
}

gen_svg()
{
    msg "Generating $PROJNAME$VERS.svg..."
    GC="${GC:=gnuclad}"
    command -v "$GC" >/dev/null || die "gnuclad not found"
    "$GC" "$PROJNAME.csv" "dist/$PROJNAME$VERS.svg" "$PROJNAME.conf" || exit 1
    msg "Generated dist/$PROJNAME$VERS.svg"
    tl_run=1
}

gen_png() {
    [ "$tl_run" ] || gen_svg
    msg "Generating $PROJNAME$VERS.png..."
    command -v convert >/dev/null || (warn "ImageMagick not found! PNG not generated"; return 1)
    convert "dist/$PROJNAME$VERS.svg" "dist/$PROJNAME$VERS.png"
    msg "Generated dist/$PROJNAME$VERS.png"
    png_run=1
}

dist() {
    [ "$tl_run" ]              || gen_svg
    [ "$png_run" ]             || gen_png
    msg "Generating $PROJNAME$VERS.tar.gz ..."
    command -v tar  >/dev/null || die "tar not found"
    command -v gzip >/dev/null || die "gzip not found"

    tar cf "dist/$PROJNAME$VERS.tar" "$PROJNAME.csv" "$PROJNAME.conf" CHANGELOG README.md LICENSE images build.sh CONTRIBUTING
    gzip -f "dist/$PROJNAME$VERS.tar"

    msg "Generated dist/$PROJNAME$VERS.tar.gz"
}

# shellcheck disable=2016
usage() {
    msg "Usage: $0 [opt]"
    msg '   svg             Generate the timeline in SVG format'
    msg '   png             Generate a PNG file of the timeline'
    msg '   help            Display help'
    msg '   (any other)     Create a distribution tarball with the specified name'
    msg 'Accepted environment variables:'
    msg '   $GC             Path for gnuclad'
    msg '   $PROJNAME       Project name (default: ldt)'
}

main() {
    [ -d dist ] || mkdir -p dist
    case $1 in
        'svg') shift; VERS="$1"; gen_svg ;;
        'png') shift; VERS="$1"; gen_png ;;
        '-h'|'help') usage ;;
        *) VERS="$1"; dist ;;
    esac
}

main "$@"
