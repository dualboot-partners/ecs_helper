FROM ruby:3.0.2-alpine3.12

RUN apk update && apk upgrade
RUN apk add bash
RUN apk add curl-dev ruby-dev build-base git curl ruby-json openssl apache2-utils sqlite-libs sqlite sqlite-dev

RUN mkdir -p /gem
WORKDIR /gem

COPY lib/ecs_helper/version.rb /gem/lib/ecs_helper/
COPY ecs_helper.gemspec /gem/
COPY Gemfile* /gem/
RUN bundle install --jobs 4

COPY . /gem
