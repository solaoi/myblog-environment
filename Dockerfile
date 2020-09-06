FROM debian:jessie

MAINTAINER kodai.aoyama@gmail.com

RUN apt-get -qq update \
        && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends apt-utils ca-certificates curl zip

# Install git (for git submodule)
RUN apt-get -qq update \
        && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends git-core

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get -qq install -y nodejs
RUN npm install -g workbox-cli

# Install pngquanti, jpegtran (for image resize)
RUN apt-get -qq update \
        && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends pngquant libjpeg-turbo-progs

RUN rm -fr /var/lib/apt/lists/*

# Download and install guetzli
ENV GUETZLI_VERSION 1.0.1

ADD https://github.com/google/guetzli/releases/download/v${GUETZLI_VERSION}/guetzli_linux_x86-64 /usr/local/bin/guetzli
RUN chmod 755 /usr/local/bin/guetzli

# Download and install hugo
ENV HUGO_VERSION 0.70.0
ENV HUGO_TARBALL hugo_${HUGO_VERSION}_Linux-64bit.tar.gz

ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TARBALL} /usr/local/
RUN tar xzf /usr/local/${HUGO_TARBALL} -C /usr/local/ \
        && rm -r /usr/local/${HUGO_TARBALL} \
        && mv /usr/local/hugo /usr/bin

# Create working directory
RUN mkdir /usr/share/blog
WORKDIR /usr/share/blog

# Expose default hugo port
EXPOSE 1313

# Automatically build site
ONBUILD ADD site/ /usr/share/blog
ONBUILD RUN hugo -d /usr/share/nginx/html/

# By default, serve site
ENV HUGO_BASE_URL http://localhost:1313
CMD hugo server -b ${HUGO_BASE_URL}