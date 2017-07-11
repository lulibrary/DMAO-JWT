FROM dmaonline/ruby-base:2.3.1

ENV APP_ROOT /var/www/docker-sinatra
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
ADD Gemfile* $APP_ROOT/
RUN bundle install
ADD . $APP_ROOT

COPY docker/entrypoint.sh /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bundle", "exec", "rackup", "config.ru", "-p", "80", "-s", "puma", "-o", "0.0.0.0"]
