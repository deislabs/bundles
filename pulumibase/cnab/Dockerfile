FROM node:latest

RUN apt-get update && apt-get -y install curl

# this is currently the official installation guide for Linux
RUN curl -fsSL https://get.pulumi.com | sh

COPY app /cnab/app

# add the pulumi bin directory to the path
ENV PATH="/root/.pulumi/bin:${PATH}"
