FROM ubuntu:22.04

# @todo ImageMagick not working
RUN apt-get update && apt-get -y install curl inkscape && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV GNUCLAD_VERSION="0.2.4"
RUN GNUCLAD_VERSION_SHORT=`echo ${GNUCLAD_VERSION} | cut -d. -f1-2` && \
    curl -o /tmp/gnuclad.tar.gz -fsSL "https://launchpad.net/gnuclad/trunk/${GNUCLAD_VERSION_SHORT}/+download/gnuclad-${GNUCLAD_VERSION}_amd64_debsource.tar.gz" && \
    tar -C /tmp -xf /tmp/gnuclad.tar.gz && \
    dpkg-deb --build /tmp/gnuclad-${GNUCLAD_VERSION}_amd64 && \
    dpkg -i /tmp/gnuclad-${GNUCLAD_VERSION}_amd64.deb && \
    rm -rf /tmp/gnuclad-${GNUCLAD_VERSION}_amd64 /tmp/gnuclad-${GNUCLAD_VERSION}_amd64.deb

# Simple fix for inkscape
RUN mkdir -p /.config/inkscape && chmod 777 /.config/inkscape

WORKDIR /app
CMD ["./build-docker.sh"]
