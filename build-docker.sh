#!/usr/bin/env bash

changeLinksInSVG() {
    svgFile="${1}"

    # Change links to distrowatch
    #sed -i "s|https://distroware.gitlab.io/os/Linux/[a-z0-9]/|https://distrowatch.com/table.php?distribution=|g" ${svgFile}

    # Append target blank
    sed -i "s|xlink:href|target=\"_blank\" xlink:href|g" ${svgFile}
}

if [ ! -d dist ]; then
    mkdir dist
fi

files=(
    "ldt.csv"
)
for file in "${files[@]}"; do
    # Generate SVG
    gnuclad "${file}" "dist/${file/%csv/svg}" "${file/%csv/conf}"

    # Change links in SVG
    changeLinksInSVG "dist/${file/%csv/svg}"
done
# Doublicated, because creating a svg is faster than a image
for file in "${files[@]}"; do
    # Convert svg to image
    inkscape --export-filename="dist/${file/%csv/png}" "dist/${file/%csv/svg}"
done
