FROM ruby:2.7.1

MAINTAINER Jihane Najdi <jnajdi@vt.edu>

# Default environment
ARG RAILS_ENV='development'
# Ruby changed the way optional params are done, but Rails hasn't caught up
ARG RUBYOPT='-W:no-deprecated'
ARG BASEDIR='/code-workout'

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#install 'development tools' build-essential  dkms curl libxslt-dev libpq-dev python-dev python-pip python-feedvalidator python-software-properties python-sphinx libmariadbclient-dev libcurl4-gnutls-dev libevent-dev libffi-dev libssl-dev stunnel4 libsqlite3-dev
#    libmariadbclient-dev
RUN apt-get update -qq \
    && apt-get install -y \
      apt-utils \
      build-essential \
      libpq-dev \
      vim \
      cron \
      curl \
      nodejs \
      python-pip \
      git-core \
      zlib1g-dev \
      libssl-dev \
      libreadline-dev \
      libyaml-dev \
      libevent-dev \
      libsqlite3-dev \
      libsqlite3-dev \
      libxml2-dev \
      libxml2 \
      libxslt1-dev \
      libffi-dev \
      libxslt-dev \
      sqlite3 \
      dkms \
      python-dev \
      python-feedvalidator \
      python-sphinx \
      ant \
      default-jre \
      default-jdk \
    && pip install --upgrade pip

## JAVA INSTALLATION
RUN apt-get install -y default-jre default-jdk

# install rubygems
ENV BUNDLER_VERSION 2.1.4
ENV RAILS_ENV=$RAILS_ENV

RUN gem install bundler -v $BUNDLER_VERSION

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

#RUN bundle update
#RUN bundle check || bundle install
RUN bundle install

#VOLUME ${BASEDIR}
WORKDIR ${BASEDIR}

COPY runservers.sh runservers.sh

RUN find /code-workout -type d -exec chmod 2775 {} \;
RUN find /code-workout -type f -exec chmod 0644 {} \;
RUN find ./runservers.sh -type f -exec chmod +x {} \;

EXPOSE 80

CMD ["bash", "./runservers.sh"]
