FROM ruby:2.7.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y nodejs build-essential libpq-dev yarn
RUN mkdir /prtimes-scraping
WORKDIR /prtimes-scraping

COPY Gemfile /prtimes-scraping/Gemfile
# COPY Gemfile.lock /prtimes-scraping/Gemfile.lock

RUN gem install bundler && bundle install --path vendor/bundle --without test development
RUN bundle update webdrivers selenium-webdriver

RUN yarn install --check-files

COPY . /prtimes-scraping