FROM ruby:2.3.8

LABEL MAINTAINER Jihane Najdi <jnajdi@vt.edu>

# Default environment
ARG RAILS_ENV='development'
ARG BASEDIR='/code-workout/'

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
    && pip install --upgrade pip

# install rubygems
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
ENV BUNDLER_VERSION 1.17.3 
ENV RAILS_ENV=$RAILS_ENV

RUN gem install bundler -v $BUNDLER_VERSION \
	&& bundle config --global path "$GEM_HOME" \
	&& bundle config --global bin "$GEM_HOME/bin" \
	&& bundle config git.allow_insecure true

VOLUME ${BASEDIR}
WORKDIR ${BASEDIR}

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle update
RUN bundle check || bundle install

COPY runservers.sh runservers.sh

RUN find /code-workout -type d -exec chmod 2775 {} \;
RUN find /code-workout -type f -exec chmod 0644 {} \;
RUN find ./runservers.sh -type f -exec chmod +x {} \;

EXPOSE 80

## JAVA INSTALLATION
RUN apt-get install -y default-jre

CMD ["bash", "./runservers.sh"]
