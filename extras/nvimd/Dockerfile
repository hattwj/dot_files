FROM alpine:latest

##
# Set the default locale, otherwise vim will have odd characters in it
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apk add --no-cache neovim

RUN adduser -D app
USER app
WORKDIR /home/app
