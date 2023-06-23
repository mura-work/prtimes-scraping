FROM ruby:2.7.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Chrome のインストール
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add \
  && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qq \
  && apt-get install -y nodejs build-essential libpq-dev yarn chromium libnss3 libgconf-2-4

# ChromeDriver のインストール
# 現在の最新のバージョンを取得し、それをインストールする。
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` \
  && curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver_linux64.zip \
  && mv chromedriver /usr/local/bin/

RUN mkdir /prtimes-scraping
WORKDIR /prtimes-scraping

COPY Gemfile /prtimes-scraping/Gemfile
COPY Gemfile.lock /prtimes-scraping/Gemfile.lock

RUN gem install bundler && bundle install --without test development
RUN bundle update webdrivers selenium-webdriver

RUN yarn install --check-files

COPY . /prtimes-scraping

# コンテナ起動時に実行させるスクリプトを追加
# COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]
# EXPOSE 3000

# # Rails サーバ起動
# CMD ["rails", "server", "-b", "0.0.0.0"]