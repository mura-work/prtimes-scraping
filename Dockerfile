FROM ruby:2.7.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Chrome のインストール
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google.list
RUN apt-get update -qq
RUN apt-get install -y nodejs build-essential libpq-dev yarn google-chrome-stable libnss3 libgconf-2-4

# ChromeDriver のインストール
# 現在の最新のバージョンを取得し、それをインストールする。
RUN wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip && rm chromedriver_linux64.zip
RUN mv chromedriver /usr/local/bin/

RUN mkdir /prtimes-scraping
WORKDIR /prtimes-scraping

COPY Gemfile /prtimes-scraping/Gemfile
COPY Gemfile.lock /prtimes-scraping/Gemfile.lock

RUN gem install bundler && bundle install --without test development
RUN bundle update webdrivers selenium-webdriver

RUN yarn install --check-files

COPY . /prtimes-scraping
