#######################
### BASE (FIRST)
#######################

FROM quay.io/criticaljuncture/baseimage:16.04

# Update apt
RUN apt-get update && apt-get install vim curl build-essential -y


#######################
### RUBY
#######################

RUN apt-get install software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update && apt-get install -y ruby1.9.3 ruby1.9.1-dev


#######################
### VARIOUS PACKAGES
#######################

RUN apt-get update &&\
  apt-get install -y patch libcurl4-openssl-dev libpcre3-dev git libmysqlclient-dev mysql-client &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

RUN apt-get update &&\
  apt-get install -y apache2-utils fontconfig hunspell-en-us libcurl4-gnutls-dev libhunspell-1.3-0 libhunspell-dev pngcrush secure-delete xfonts-75dpi xfonts-base xpdf &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# node js - packages are out of date
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# npm packages for testing
RUN npm install -g jshint


#######################
### SPHINX
#######################

WORKDIR /tmp
RUN curl -O http://sphinxsearch.com/files/sphinx-2.1.2-release.tar.gz
RUN tar xzvf sphinx-2.1.2-release.tar.gz
WORKDIR /tmp/sphinx-2.1.2-release
RUN ./configure
RUN make
RUN make install

WORKDIR /


#######################
### EBS BACKUPS
#######################

RUN add-apt-repository ppa:alestic &&\
  apt-get update &&\
  apt-get install -y ec2-consistent-snapshot &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/


##################
### TIMEZONE
##################

RUN ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime


##################
### SERVICES
##################

COPY docker/api/service/api/run /etc/service/api/run
COPY docker/api/my_init.d /etc/my_init.d
COPY docker/api/service/resque_worker_1/run /etc/service/resque_worker_1/run
COPY docker/api/service/resque_worker_2/run /etc/service/resque_worker_2/run
COPY docker/api/service/resque_worker_3/run /etc/service/resque_worker_3/run

RUN adduser app -uid 1000 --system
RUN usermod -a -G docker_env app


###############################
### GEMS & PASSENGER INSTALL
###############################

RUN gem install bundler
WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --system --full-index &&\
  passenger-config install-standalone-runtime &&\
  passenger start --runtime-check-only

ENV PASSENGER_MIN_INSTANCES 1
ENV WEB_PORT 3000


##################
### APP
##################

COPY . /home/app/

WORKDIR /home/app
RUN chown -R app /home/app


##################
### BASE (LAST)
##################

# ensure all packages are up to date
RUN apt-get update && unattended-upgrade -d

# set terminal
ENV TERM=linux
