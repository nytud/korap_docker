FROM ubuntu:16.04

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get dist-upgrade -y

RUN apt-get install -y \
    apt-utils \
    build-essential \
    bzip2 \
    curl \
    debconf \
    git \
    libxml2-dev \
    maven \
    openjdk-8-jdk \
    perlbrew \
    ruby \
    ;

RUN apt-get autoremove -y && apt-get autoclean 

RUN perlbrew init \
    ; echo 'source ~/perl5/perlbrew/etc/bashrc' >>~/.bashrc \
    ; source ~/perl5/perlbrew/etc/bashrc \
    ; perlbrew install --noman --thread perl-5.30.1 \
    ; perlbrew switch perl-5.30.1 \
    ; perlbrew install-cpanm \
    ;

RUN source ~/perl5/perlbrew/etc/bashrc \
    ; cpanm git://github.com/Akron/Mojolicious-Plugin-Localize.git \
    ; cpanm git://github.com/Akron/Mojolicious-Plugin-TagHelpers-ContentBlock.git \
    ;

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    ; apt-get install -y nodejs \
    ; npm install -g sass \
    ; npm install -g grunt-cli \
    ; npm install grunt \
    ;

WORKDIR /app

# Koral
COPY Koral /app/Koral
RUN cd /app/Koral ; mvn clean install

# Krill
COPY Krill /app/Krill
RUN cd /app/Krill ; mvn clean install

# Kustvakt
COPY Kustvakt /app/Kustvakt
RUN cd /app/Kustvakt/core ; mvn clean install
RUN cd /app/Kustvakt/lite ; mvn clean package

# Kalamar
COPY Kalamar /app/Kalamar
RUN source ~/perl5/perlbrew/etc/bashrc \
    ; cd /app/Kalamar \
    ; cpanm --installdeps . \
    ;
RUN cd /app/Kalamar \
    ; npm install \
    ; grunt \
    ;


RUN sed -e 's#^krill\.indexDir\s*=\s*.*$#krill.indexDir=/app/index/#gm' \
    -e 's#^server\.port\s*=\s*.*$#server.port=5556#gm' \
    /app/Kustvakt/lite/src/main/resources/kustvakt-lite.conf \
    > /app/Kustvakt/lite/target/kustvakt-lite.conf 

RUN echo "$(tr -cd '[:alnum:]' < /dev/urandom | head -c${1:-32})" > Kalamar/kalamar.secret

RUN sed -r 's#^  },\s*$#  },\n  hypnotoad => {\n    listen => ['\''http://*:5555'\''],\n    workers => 5,\n    inactivity_timeout => 120,\n    proxy => 1\n  },#g' \
    Kalamar/kalamar.conf \
    >Kalamar/kalamar.hnc.conf \
    ; sed -ir 's/# experimental_proxy => 1,/experimental_proxy => 1,/' Kalamar/kalamar.hnc.conf \
    ;


COPY entrypoint.sh /app

ENTRYPOINT [ "/app/entrypoint.sh" ]