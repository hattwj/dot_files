FROM alpine:latest

##
# Set the default locale, otherwise vim will have odd characters in it
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apk add neovim


USER app
WORKDIR /home/app
