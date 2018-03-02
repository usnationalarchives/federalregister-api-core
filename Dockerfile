#######################
### BASE (FIRST)
#######################

FROM quay.io/criticaljuncture/baseimage:16.04

# Update apt - add gettext for ENV var substitution in tmpl files
RUN apt-get update && apt-get install vim curl build-essential gettext-base -y


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


##################
### WKHTML2PDF
##################

WORKDIR /tmp

RUN apt-get update &&\
  apt-get install -y xfonts-75dpi xfonts-base pdftk &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

RUN curl -OL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar -xvf /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN cp /tmp/wkhtmltox/bin/wkhtmltopdf /usr/local/bin/


##################
### PRINCEXML
##################

RUN apt-get update &&\
  apt-get install -y libc6 libtiff5 libgif7 libcurl3 libfontconfig1 libjpeg8 &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

WORKDIR /tmp

# install prince and license template
RUN curl -O  http://www.princexml.com/download/prince-8.1r5-ubuntu1604-amd64.tar.gz
RUN tar -xzvf prince-8.1r5-ubuntu1604-amd64.tar.gz
WORKDIR /tmp/prince-8.1r5-ubuntu1604-amd64
RUN ./install.sh

COPY docker/api/files/princexml.json.tmpl /usr/local/lib/prince/license/license.dat.tmpl

# add fonts
COPY docker/api/files/fonts/open-sans /usr/share/fonts/truetype/
# update font cache
RUN  fc-cache -f -v


##################
### IMAGEMAGICK
##################

RUN apt-get update &&\
  apt-get install -y checkinstall libtiff5-dev libx11-dev libxext-dev zlib1g-dev libpng12-dev libjpeg-dev &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

WORKDIR /tmp

#RUN apt-get build-dep imagemagick
RUN curl -O https://www.imagemagick.org/download/ImageMagick-6.9.9-36.tar.xz
RUN tar -xvf ImageMagick-6.9.9-36.tar.xz

WORKDIR /tmp/ImageMagick-6.9.9-36
RUN ./configure && make
RUN make install
RUN ldconfig /usr/local/lib


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
RUN mkdir -p /home/app/log
RUN mkdir -p /home/app/pids
RUN mkdir -p /home/app/tmp/pids
RUN chown -R app /home/app


##################
### BASE (LAST)
##################

# ensure all packages are up to date
RUN apt-get update && unattended-upgrade -d

# set terminal
ENV TERM=linux
