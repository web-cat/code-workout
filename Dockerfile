FROM ruby:2.7.1
#FROM ruby:2.3.3

MAINTAINER Jihane Najdi <jnajdi@vt.edu>

#Default environment
ARG RAILS_ENV='development'
ARG BASEDIR='/code-workout/'

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#install 'development tools' build-essential  dkms curl libxslt-dev libpq-dev python-dev python-pip python-feedvalidator python-software-properties python-sphinx libmariadbclient-dev libcurl4-gnutls-dev libevent-dev libffi-dev libssl-dev stunnel4 libsqlite3-dev
#    libmariadbclient-dev
RUN apt-get update -qq \
    && apt-get install -y apt-utils build-essential libpq-dev  vim cron curl \
    && apt-get install -y nodejs npm python-pip git-core zlib1g-dev libssl-dev libreadline-dev libyaml-dev  libevent-dev libsqlite3-dev libsqlite3-dev     libxml2-dev   libxml2  libxslt1-dev   libffi-dev    libxslt-dev   sqlite3   dkms  python-dev python-feedvalidator     python-sphinx  \
    && pip install --upgrade pip
#// libcurl4-openssl-dev
# #// libcurl4

#RUN  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 \
#    && apt-get install -y apt-transport-https ca-certificates \
#    && sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list' \
#    && apt-get update \
#    && apt-get install -y passenger

# install rubygems
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
ENV BUNDLER_VERSION 2.1.4
ENV RAILS_ENV=$RAILS_ENV

RUN gem install bundler -v $BUNDLER_VERSION \
	&& bundle config --global path "$GEM_HOME" \
	&& bundle config --global bin "$GEM_HOME/bin" \
	&& bundle config git.allow_insecure true

# Create a user with the same UID as host user so we have permissions
# RUN useradd -r -u ${UID} appuser
# USER appuser

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
#EXPOSE 3000

# Create the log file
# RUN touch /code-workout/log/development.log

# Redirecting logs to Dockerlog collector   accesslogs (/proc/1/fd/1)  errorlogs (/proc/self/fd/2)
#RUN ln -sf /proc/1/fd/1 /opendsa-lti/log/development.log

# Clone OpenDSA
# RUN mkdir /opendsa
# RUN git clone https://github.com/OpenDSA/OpenDSA.git /opendsa
# RUN pip install -r /opendsa/requirements.txt --upgrade
# RUN ln -s /opendsa /opendsa-lti/public/OpenDSA
# RUN ln -s "$(which nodejs)" /usr/local/bin/node
# RUN cp /opendsa-lti/postprocessor.py /opendsa-lti/public/OpenDSA/tools/postprocessor.py

## JAVA INSTALLATION
RUN apt-get install -y default-jre

### OpenDSA libraries for Python 2.7
# RUN pip install --upgrade beautifulsoup4
# RUN pip install --upgrade html5lib

#ln -s /opendsa/RST /opendsa-lti/RST
#ln -s /opendsa/config /opendsa-lti/Configuration
#rm /opendsa-ltiConfiguration/config
#rm /opendsa-lti/RST/RST

##RUN bundle
#RUN echo $PATH

CMD ["bash", "./runservers.sh"]

#CMD tail -f /dev/null & wait
