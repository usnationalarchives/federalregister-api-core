#######################
### BASE (FIRST)
#######################

FROM quay.io/criticaljuncture/baseimage:20.04


#######################
### RUBY
#######################

ARG RUBY_VERSION=3.1-jemalloc

# install ruby
RUN apt update && \
  apt install -y \
    # ruby
    fullstaq-ruby-common fullstaq-ruby-${RUBY_VERSION} &&\
  apt-get clean &&\
  apt-get autoremove &&\
  apt-get purge &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

#######################
### VARIOUS PACKAGES
#######################

RUN apt-get update &&\
  apt-get install -y gettext-base patch libpcre3-dev git libmysqlclient-dev libssl-dev mysql-client \
    apache2-utils fontconfig hunspell-en-us libhunspell-1.7-0 libhunspell-dev pngcrush secure-delete \
    xfonts-75dpi xfonts-base tzdata \
    # used for de-scrunching GPO images
    dynamite \
    # used for curb gem
    libcurl4 libcurl3-gnutls libcurl4-openssl-dev \
    # Required to successfully compile qpdf
    libjpeg-dev \
    # Used for pdftotext call in PI importer
    poppler-utils \
    # used for mimemagic gem installation
    shared-mime-info &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

##################
### COMPILE/INSTALL QPDF
##################
WORKDIR /usr/local
RUN git clone -b 10.6 --single-branch https://github.com/qpdf/qpdf
WORKDIR /usr/local/qpdf
RUN ./configure && make && make install
  # export LD_LIBRARY_PATH=/usr/local/lib
WORKDIR /

##################
### Node JS
##################

# node js - packages are out of date
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - &&\
  apt-get install -y nodejs &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# npm packages for testing
RUN npm install -g jshint

##################
### IMAGEMAGICK
##################

RUN apt-get update &&\
  apt-get update && apt-get install -y checkinstall libtiff5-dev libx11-dev libxext-dev zlib1g-dev libpng-dev libjpeg-dev ghostscript libgs-dev imagemagick &&\
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
  usermod -a -G crontab app &&\
  # Add app user to teletypewriter group so passenger can log to stdout
  usermod -a -G tty app

# switch to app user automatically when exec into container
RUN echo 'su - app -s /bin/bash' | tee -a /root/.bashrc

# rotate logs
COPY docker/api/files/logrotate/app /etc/logrotate.d/app
COPY docker/api/files/logrotate/persist_logs.sh /opt/persist_logs.sh

###############################
### ADDITIONAL RUBY SETUP
###############################
RUN chown -R app /usr/lib/fullstaq-ruby

# make available in default path
ENV PATH "/usr/lib/fullstaq-ruby/versions/${RUBY_VERSION}/bin:${PATH}"
USER app
ENV PATH "/usr/lib/fullstaq-ruby/versions/${RUBY_VERSION}/bin:${PATH}"
USER root

###############################
### GEMS & PASSENGER INSTALL
###############################

# add env for sidekiq-pro credentials
ARG SIDEKIQ_CREDENTIALS
ENV BUNDLE_GEMS__CONTRIBSYS__COM=$SIDEKIQ_CREDENTIALS
RUN gem install bundler -v 2.3.21
WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle config set --local system 'true'
RUN bundle install --full-index &&\
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
