FROM debian:testing

# File Author / Maintainer
MAINTAINER Ewan Higgs <ewan_higgs@yahoo.co.uk>

ENV DEBIAN_FRONTEND=noninteractive

ENV C_DEPS="libcsv-dev"
ENV CPP_DEPS="libboost-dev"
ENV R_DEPS="r-base r-base-dev libopenblas-base"
ENV PYTHON2_DEPS="python python-dev python-pip"
ENV PYTHON3_DEPS="python3 python3-dev python3-pip"
ENV RUBY_DEPS="ruby"
ENV LUA_DEPS="lua5.1 luajit luarocks"
ENV GOLANG_DEPS="golang"
ENV HASKELL_DEPS="ghc libghc-text-dev libghc-cassava-dev"
ENV OCAML_DEPS="ocaml opam"
ENV JULIA_DEPS="julia"
ENV PHP_DEPS="php7.0"

# General tools
RUN apt-get update && \
    apt-get install \
       ca-certificates \
       curl \
       dirmngr \
       gcc \
       gnupg \
       libc6-dev \
       $C_DEPS \
       $CPP_DEPS \
       $R_DEPS \
       $JAVA_DEPS \
       $PYTHON2_DEPS \
       $PYTHON3_DEPS \
       $OCAML_DEPS \
       $RUBY_DEPS \
       $LUA_DEPS \
       $GOLANG_DEPS \
       $HASKELL_DEPS \
       $JULIA_DEPS \
       $PHP_DEPS \
       -qqy \
       --no-install-recommends


# Oracle Java
#RUN apt-get -q install --no-install-recommends -y software-properties-common
#RUN add-apt-repository -y ppa:webupd8team/java
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
      tee /etc/apt/sources.list.d/webupd8team-java.list; \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
      tee -a /etc/apt/sources.list.d/webupd8team-java.list; \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get -q update 

# Auto-accept the Oracle JDK license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | \
    /usr/bin/debconf-set-selections
RUN apt-get -q install --no-install-recommends -y oracle-java8-installer

# Apps that require Java
RUN apt-get -q install --no-install-recommends -y \
    ant \
    maven
    
RUN rm -rf /var/lib/apt/lists/*

# Python
RUN pip install pandas
# Lua
RUN luarocks install lpeg
# Perl
# Perl seems to install Text::CSV_XS just fine but still gives error code 8.
RUN cpan install perl Text::CSV_XS ; exit 0
# OCaml
# OCaml seems to fail. If you're bored and come across this, help me fix it,
# pls. :)
#RUN opam init && opam install -y csv

#Rust
RUN mkdir /rust
RUN pwd
WORKDIR /rust

# Rust
ENV RUST_ARCHIVE=rust-nightly-x86_64-unknown-linux-gnu.tar.gz
ENV RUST_DOWNLOAD_URL=https://static.rust-lang.org/dist/$RUST_ARCHIVE

RUN curl -fsOSL $RUST_DOWNLOAD_URL \
    && curl -s $RUST_DOWNLOAD_URL.sha256 | sha256sum -c - \
    && tar -C /rust -xzf $RUST_ARCHIVE --strip-components=1 \
    && rm $RUST_ARCHIVE \
    && ./install.sh

# Clojure
ENV LEIN_ROOT 1

# Install Leiningen and make executable
RUN curl -s https://raw.githubusercontent.com/technomancy/leiningen/2.6.1/bin/lein > \
            /usr/local/bin/lein && \
            chmod 0755 /usr/local/bin/lein && \
            /usr/local/bin/lein

WORKDIR /

