FROM quay.io/criticaljuncture/baseimage:16.04

RUN apt-get install software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update && apt-get install -y ruby1.9.3 ruby1.9.1-dev

RUN apt-get update &&\
  apt-get install -y build-essential patch libcurl4-openssl-dev libpcre3-dev git libmysqlclient-dev &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

RUN apt-get update &&\
  apt-get install -y apache2-utils fontconfig hunspell-en-us libcurl4-gnutls-dev libhunspell-1.3-0 libhunspell-dev pngcrush secure-delete xfonts-75dpi xfonts-base xpdf &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# Install Sphinx
WORKDIR /tmp
RUN curl -O http://sphinxsearch.com/files/sphinx-2.1.2-release.tar.gz
RUN tar xzvf sphinx-2.1.2-release.tar.gz
WORKDIR /tmp/sphinx-2.1.2-release
RUN ./configure
RUN make
RUN make install

WORKDIR /

#RUN add-apt-repository ppa:builds/sphinxsearch-rel22
#RUN apt-get update && apt-get install -y sphinxsearch

# EBS backups
RUN add-apt-repository ppa:alestic &&\
  apt-get update &&\
  apt-get install -y ec2-consistent-snapshot &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# api-core rake version that is compatible with 2.3.x
RUN gem install rake --version 10.5.0
# rack version compatible with 1.9.3
RUN gem install rack --version 1.6.4
RUN gem install passenger --version 5.0.30
RUN passenger-config install-standalone-runtime &&\
  passenger-config build-native-support &&\
  passenger start --runtime-check-only

RUN ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime

COPY docker/api/service/api/run /etc/service/api/run
COPY docker/api/my_init.d /etc/my_init.d

RUN adduser app -uid 1000 --system

RUN gem install bundler --version 1.13.6
WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --system --full-index

COPY . /home/app/

WORKDIR /home/app
RUN chown -R app /home/app

ENV TERM=linux
