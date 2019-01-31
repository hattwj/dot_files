FROM ruby:2.3.7

RUN gem install rubocop && \
  gem install parser && \
  gem install rails_best_practices && \
  gem install unparser && \
  gem install reek

RUN apt update && \
  apt install -y curl

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -

RUN apt install -y nodejs && \
  npm install -g jsonlint && \
  npm install -g jq \
  npm install -g eslint && \
  npm install -g prettier && \
  npm install -g babel-cli babel-preset-flow flow-bin

# Add a fancy differ
RUN npm install -g diff-so-fancy

RUN apt install -y \
  vim-gtk3 \
  python-pip

RUN pip install \
    flake8

RUN useradd -ms /bin/bash app

# Create dir for mounting src
RUN mkdir /src

USER app
WORKDIR /home/app
