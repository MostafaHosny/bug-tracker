FROM ruby:2.3.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /bug-tracker
WORKDIR /bug-tracker
ADD Gemfile /bug-tracker/Gemfile
ADD Gemfile.lock /bug-tracker/Gemfile.lock
RUN bundle install
ADD . /bug-tracker
EXPOSE 5672 15672


