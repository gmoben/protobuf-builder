FROM debian:jessie

USER root

RUN apt-get update

# Install basics
RUN apt-get install -y git
RUN apt-get install -y zip
RUN apt-get install -y wget
RUN apt-get install -y tree

# Install 3.1.0 protobuf compiler and definitions
RUN cd /tmp && \
wget https://github.com/google/protobuf/releases/download/v3.1.0/protoc-3.1.0-linux-x86_64.zip \
&& unzip protoc*.zip -d pb \
&& cp pb/bin/* /usr/bin \
&& cp -R pb/include /usr/bin/include

# Go-related protobuf requirements
ENV GOPATH /root/gocode
ENV PATH $GOPATH/bin:$PATH
RUN apt-get install -y golang

RUN mkdir $GOPATH
RUN go get github.com/golang/protobuf/protoc-gen-go

# Python-related requirements
RUN apt-get install -y python
RUN apt-get install -y python-setuptools
RUN apt-get install -y python-stdeb
RUN apt-get install -y dh-python
