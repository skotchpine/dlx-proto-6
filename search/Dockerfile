FROM ruby:2.4.1-alpine
MAINTAINER Tyler <tyler@skotchpine.com>

ADD Gemfile /

RUN bundle install

ADD search.rb /
ADD config.rb /

CMD ["/search.rb"]
