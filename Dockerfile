FROM ruby:2.6.3

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN curl -SL https://deb.nodesource.com/setup_11.x | bash
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends libidn11-dev nodejs yarn

RUN apt-get install -y build-essential libpq-dev unzip && \
  CHROME_DRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
  wget -N http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/ && \
  unzip ~/chromedriver_linux64.zip -d ~/ && \
  rm ~/chromedriver_linux64.zip && \
  chown root:root ~/chromedriver && \
  chmod 755 ~/chromedriver && \
  mv ~/chromedriver /usr/bin/chromedriver && \
  sh -c 'wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' && \
  sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
  apt-get update && apt-get install -y google-chrome-stable

RUN rm -rf /var/lib/apt/lists/*
RUN gem install bundler

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN mkdir /webpack_pure
WORKDIR /webpack_pure

COPY Gemfile /webpack_pure/Gemfile
COPY Gemfile.lock /webpack_pure/Gemfile.lock

# install gems
RUN bundle install

# yarn install
RUN yarn install --force