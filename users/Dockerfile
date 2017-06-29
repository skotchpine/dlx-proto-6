FROM aseith/ruby-sqlite-sinatra-alpine

ARG PORT
ARG BIND

ADD users.rb /
ADD config.rb /
ADD Gemfile /

RUN bundle install

ENV PORT ${PORT}
ENV BIND ${BIND}

CMD ["/users.rb"]
