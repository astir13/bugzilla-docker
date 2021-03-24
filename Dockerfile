FROM ubuntu:20.04
LABEL maintainer="Stefan Pielmeier <stefan@symlinux.com>"
LABEL version 0.2
LABEL description="Docker image for bugzilla on Ubuntu 20.04 using PerlCGI/Apache2"

ENV bugzilla_branch=release-5.0-stable
ENV APACHE_USER=www-data

# disable prompt during package install
ARG DEBIAN_FRONTEND=noninteractive

##################
##   BUILDING   ##
##################

WORKDIR /

# Prerequisites
RUN apt update
RUN apt-get upgrade -y
RUN apt-get install -y \
      vim \
      bash \
      supervisor \
      libappconfig-perl \
      libdate-calc-perl \
      libtemplate-perl \
      libmime-tools-perl \
      build-essential \
      libdatetime-timezone-perl \
      libdatetime-perl \
      libemail-sender-perl \
      libemail-mime-perl \
      libemail-mime-perl \
      libdbi-perl \
      libdbd-mysql-perl \
      libcgi-pm-perl \
      libmath-random-isaac-perl \
      libmath-random-isaac-xs-perl \
      libapache2-mod-perl2 \
      libapache2-mod-perl2-dev \
      libchart-perl \
      libxml-perl \
      libxml-twig-perl \
      perlmagick \
      libgd-graph-perl \
      libtemplate-plugin-gd-perl \
      libsoap-lite-perl \
      libhtml-scrubber-perl \
      libjson-rpc-perl \
      libdaemon-generic-perl \
      libtheschwartz-perl \
      libtest-taint-perl \
      libauthen-radius-perl \
      libfile-slurp-perl \
      libencode-detect-perl \
      libmodule-build-perl \
      libnet-ldap-perl \
      libfile-which-perl \
      libauthen-sasl-perl \
      libfile-mimeinfo-perl \
      libhtml-formattext-withlinks-perl \
      libgd-dev \
      libcache-memcached-perl \
      libfile-copy-recursive-perl \
      libdbd-sqlite3-perl \
      libmysqlclient-dev \
      graphviz \
      sphinx-common \
      rst2pdf \
      libemail-address-perl \
      libemail-reply-perl \
      apache2 \
      postfix \
      git
RUN rm -rf /var/lib/apt/lists/*
RUN apt clean

# prepare the entrypoint script just to start the supervisord
ADD entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 700 /etc/supervisor/conf.d/supervisord.conf

# for apache2 web server
EXPOSE 80
RUN a2enmod cgid && a2enmod rewrite && a2enmod headers && a2enmod expires
ADD bugzilla.conf /etc/apache2/conf-available
RUN a2enconf bugzilla


# install bugzilla following https://bugzilla.readthedocs.io/en/5.0/installing/linux.html
WORKDIR /var/www/html
RUN git clone --branch ${bugzilla_branch} https://github.com/bugzilla/bugzilla
RUN perl -MCPAN -e "install CPAN"

# ensure bugzilla installation and Perl is all right, this may take some time
WORKDIR /var/www/html/bugzilla
RUN ./checksetup.pl --check-modules # generates a perl module check
RUN ./install-module.pl --all  # installes missing perl modules
ADD perl_patch /tmp/perl_patch
# needed to fix Perl5 issue #17271,
# see https://stackoverflow.com/questions/56475712/getting-undefined-subroutine-utf8swashnew-called-at-bugzilla-util-pm-line-109
RUN patch -u /usr/share/perl/5.30.0/Safe.pm -i /tmp/perl_patch 
# now we can continue with normal setup
RUN ./checksetup.pl  # generates localconfig file

# make the images available for backup and restore
VOLUME /var/www/html/bugzilla/images
VOLUME /var/www/html/bugzilla/data 
VOLUME /var/www/html/bugzilla/lib

# start the supervisord
WORKDIR /tmp
CMD ["/entrypoint.sh"]
