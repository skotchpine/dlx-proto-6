FROM ruby:2.4.1-alpine
MAINTAINER Tyler <tyler@skotchpine.com>

RUN apk --update add --virtual build_deps \
      build-base ruby-dev libc-dev linux-headers \
      openssl-dev postgresql-dev

ADD Gemfile /

RUN bundle install

ADD tags.rb /
ADD config.rb /

CMD ["/tags.rb"]
