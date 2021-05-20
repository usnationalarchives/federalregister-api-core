#######################
### BASE (FIRST)
#######################

FROM quay.io/criticaljuncture/baseimage:18.04


#######################
### RUBY
#######################

RUN apt-get update && apt-get install -y ruby2.5 ruby2.5-dev &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/


#######################
### VARIOUS PACKAGES
#######################

RUN apt-get update &&\
  apt-get install -y gettext-base patch libcurl4-openssl-dev libpcre3-dev git libmysqlclient-dev libssl-dev mysql-client \
    apache2-utils fontconfig hunspell-en-us libhunspell-1.6-0 libhunspell-dev pngcrush secure-delete \
    xfonts-75dpi xfonts-base xpdf tzdata \
    # Required to successfully compile qpdf
    libjpeg-dev \
    # used for mimemagic gem installation
    shared-mime-info &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

##################
### COMPILE/INSTALL QPDF
##################
WORKDIR /usr/local
# qpdf commit: #8971443e4680fc1c0babe56da58cc9070a9dae2e
RUN git clone https://github.com/qpdf/qpdf
WORKDIR /usr/local/qpdf
RUN ./configure && make && make install
  # export LD_LIBRARY_PATH=/usr/local/lib
WORKDIR /

##################
### Node JS
##################

# node js - packages are out of date
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - &&\
  apt-get install -y nodejs &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# npm packages for testing
RUN npm install -g jshint


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
### SERVICES
##################

COPY docker/api/my_init.d /etc/my_init.d
COPY docker/api/service /etc/service


###############################
### APP USER/GROUP
###############################

RUN addgroup --gid 1000 app &&\
  adduser app -uid 1000 --gid 1000 --system &&\
  usermod -a -G docker_env app &&\
  usermod -a -G crontab app

# switch to app user automatically when exec into container
RUN echo 'su - app -s /bin/bash' | tee -a /root/.bashrc

# rotate logs
COPY docker/api/files/logrotate/app /etc/logrotate.d/app
COPY docker/api/files/logrotate/persist_logs.sh /opt/persist_logs.sh


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
### APP
##################

COPY --chown=1000:1000 . /home/app/
WORKDIR /home/app

RUN RAILS_ENV=production rake assets:precompile

##################
### BASE (LAST)
##################

# ensure all packages are as up to date as possible
# installs all updates since we last bundled
RUN apt-get update && unattended-upgrade -d

# set terminal
ENV TERM=linux
