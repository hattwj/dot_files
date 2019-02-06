FROM ruby:2.3.7

RUN apt update

##
# Set the default locale, otherwise vim will have odd characters in it
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN apt install -y locales-all

# Install required apt packages
RUN apt install -y \
    curl \
    unzip \
    less \
    jq \
    python-pip

##
# Ruby related dependencies
RUN gem install --bindir /usr/bin \
    brakeman \
    parser \
    rails_best_practices \
    reek \
    rubocop \
    unparser

# Prepare to install node
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -

##
# Node related dependencies
RUN apt install -y nodejs && \
  npm install -g jsonlint && \
  npm install -g eslint && \
  npm install -g prettier && \
  npm install -g babel-cli babel-preset-flow flow-bin

# Add a fancy differ
RUN npm install -g diff-so-fancy

##
# Python related dependencies
RUN pip install \
  flake8

# Create an unprivileged user
RUN useradd -ms /bin/bash app

# Install a newer version of vim
RUN mkdir /opt/source && \
  cd /opt/source && \
  wget https://github.com/vim/vim/archive/v8.1.0873.zip && \
  unzip v8.1.0873.zip && \
  cd vim-8.1.0873 && \
  ./configure --enable-rubyinterp && \
  make && \
  make install

USER app
WORKDIR /home/app
