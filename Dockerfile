FROM ruby
WORKDIR /usr/local/src
COPY lib/redpomo/version.rb /usr/local/src/lib/redpomo/version.rb
COPY Gemfile Gemfile.lock redpomo.gemspec /usr/local/src/
RUN bundle install
