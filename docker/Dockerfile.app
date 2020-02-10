ARG RUBY_VERSION
FROM rubylang/ruby:$RUBY_VERSION-bionic

ARG PG_MAJOR
ARG NODE_MAJOR
ARG BUNDLER_VERSION
ARG YARN_VERSION

RUN apt-get update \
  && apt-get -y install curl gnupg \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list \
  && curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

COPY docker/Aptfile /tmp/Aptfile
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  build-essential \
  libpq-dev \
  nodejs \
  postgresql-client-$PG_MAJOR \
  yarn=$YARN_VERSION-1 \
  $(cat /tmp/Aptfile | xargs) \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

ENV LANG=C.UTF-8 \
  GEM_HOME=/bundle \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
  BUNDLE_BIN=$BUNDLE_PATH/bin \
  YARN_BIN=/app/node_modules/.bin
ENV PATH /app/bin:$BUNDLE_BIN:$YARN_BIN:$PATH

RUN gem update --system \
  && gem install bundler:$BUNDLER_VERSION

WORKDIR /app
COPY docker/docker-entrypoint /docker-entrypoint
ENTRYPOINT ["/docker-entrypoint"]
