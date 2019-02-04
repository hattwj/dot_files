FROM ruby:2.3.7

RUN gem install rubocop && \
  gem install parser && \
  gem install rails_best_practices && \
  gem install unparser && \
  gem install reek

RUN apt update && \
  apt install -y curl unzip less

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
  python-pip

RUN pip install \
  flake8

RUN useradd -ms /bin/bash app

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
