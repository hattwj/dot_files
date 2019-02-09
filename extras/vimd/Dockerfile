FROM amazonlinux:latest

RUN yum update -y

##
# Set the default locale, otherwise vim will have odd characters in it
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN amazon-linux-extras install -y epel

# Install prerequisites
RUN yum install -y \
  curl \
  gcc \
  gcc-c++ \
  gdbm-devel \
  git \
  jq \
  less \
  libffi-devel \
  libyaml \
  libyaml-devel \
  make \
  nodejs \
  ncurses-devel \
  openssl-devel \
  procps \
  python-devel \
  python-pip \
  python3 \
  python3-devel \
  python3-pip \
  readline-devel \
  ruby-devel \
  tar \
  unzip \
  which \
  zlib-devel

# Import key
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

# # Install RVM
RUN curl -sSL https://get.rvm.io | bash -s
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.3.8"
RUN echo 'source /etc/profile.d/rvm.sh' >> /root/.bashrc
SHELL [ "/bin/bash", "-l", "-c" ]
##
# Ruby related dependencies
RUN gem install \
    --no-document \
    --bindir /usr/bin \
    brakeman \
    parser \
    rails_best_practices \
    reek \
    rubocop \
    unparser

##
# Node related dependencies
RUN  npm install -g jsonlint && \
  npm install -g eslint && \
  npm install -g prettier && \
  npm install -g babel-cli babel-preset-flow flow-bin

# Add a fancy differ
RUN npm install -g diff-so-fancy

##
# Python related dependencies
RUN pip install \
  flake8 \
  cfn-lint

# Create an unprivileged user
RUN useradd -ms /bin/bash app

# Install a newer version of vim
RUN mkdir /opt/source && \
  cd /opt/source && \
  curl https://codeload.github.com/vim/vim/zip/v8.1.0873 --output v8.1.0873.zip && \
  unzip v8.1.0873.zip && \
  cd vim-8.1.0873 && \
  ./configure --enable-rubyinterp && \
  make && \
  make install

USER app
WORKDIR /home/app
