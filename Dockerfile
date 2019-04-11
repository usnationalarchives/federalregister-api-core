#######################
### BASE (FIRST)
#######################

FROM quay.io/criticaljuncture/baseimage:16.04


#######################
### RUBY
#######################

RUN apt-get update && apt-get install -y ruby2.2 ruby2.2-dev &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/


#######################
### VARIOUS PACKAGES
#######################

RUN apt-get update &&\
  apt-get install -y gettext-base patch libcurl4-openssl-dev libpcre3-dev git libmysqlclient-dev mysql-client apache2-utils fontconfig hunspell-en-us libhunspell-1.3-0 libhunspell-dev pngcrush secure-delete xfonts-75dpi xfonts-base xpdf pdftk &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# node js - packages are out of date
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - &&\
  apt-get install -y nodejs &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# npm packages for testing
RUN npm install -g jshint


#######################
### SPHINX
#######################

WORKDIR /tmp
RUN curl -O http://sphinxsearch.com/files/sphinx-2.1.2-release.tar.gz &&\
  tar xzvf sphinx-2.1.2-release.tar.gz &&\
  cd /tmp/sphinx-2.1.2-release &&\
  ./configure &&\
  make &&\
  make install &&\
  rm /tmp/sphinx-2.1.2-release.tar.gz &&\
  rm -Rf /tmp/sphinx-2.1.2-release


##################
### PRINCEXML
##################

RUN apt-get update &&\
  apt-get install -y libc6 libtiff5 libgif7 libcurl3 libfontconfig1 libjpeg8 libxml2 &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

WORKDIR /tmp

# install prince and license template
RUN curl -O https://www.princexml.com/download/prince-8.1r5-ubuntu1604-amd64.tar.gz &&\
  tar -xzvf prince-8.1r5-ubuntu1604-amd64.tar.gz &&\
  cd /tmp/prince-8.1r5-ubuntu1604-amd64 &&\
  ./install.sh &&\
  rm /tmp/prince-8.1r5-ubuntu1604-amd64.tar.gz &&\
  rm -Rf /tmp/prince-8.1r5-ubuntu1604-amd64

COPY docker/api/files/princexml/license.dat.tmpl /usr/local/lib/prince/license/license.dat.tmpl

# add fonts
COPY docker/api/files/fonts/open-sans /usr/share/fonts/truetype/
# update font cache
RUN  fc-cache -f -v


##################
### IMAGEMAGICK
##################

RUN apt-get update &&\
  apt-get update && apt-get install -y checkinstall libtiff5-dev libx11-dev libxext-dev zlib1g-dev libpng12-dev libjpeg-dev ghostscript libgs-dev imagemagick &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

COPY docker/api/files/imagemagick/policy.xml /etc/ImageMagick-6/policy.xml

##################
### TIMEZONE
##################

RUN ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime


##################
### APP USER
##################

RUN adduser app -uid 1000 --system &&\
  usermod -a -G docker_env app


###############################
### GEMS & PASSENGER INSTALL
###############################

RUN gem install bundler -v 1.17.3
WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --system --full-index &&\
  passenger-config install-standalone-runtime &&\
  passenger start --runtime-check-only

# docker cached layer build optimization:
# caches the latest security upgrade versions
# at the same time we're doing something else slow (changing the bundle)
# but something we do often enough that the final unattended upgrade at the
# end of this dockerfile isn't installing the entire world of security updates
# since we set up the dockerfile for the project
RUN apt-get update && unattended-upgrade -d

ENV PASSENGER_MIN_INSTANCES 1
ENV WEB_PORT 3000


##################
### SERVICES
##################

COPY docker/api/my_init.d /etc/my_init.d
COPY docker/api/service /etc/service


##################
### APP
##################

COPY --chown=1000:1000 . /home/app/
WORKDIR /home/app


##################
### BASE (LAST)
##################

# ensure all packages are as up to date as possible
# installs all updates since we last bundled
RUN apt-get update && unattended-upgrade -d

# set terminal
ENV TERM=linux
