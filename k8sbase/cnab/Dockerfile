FROM cnab/makebase:latest

ENV HELM_LATEST_VERSION="v2.9.1"

# Install Helm and Kubectl
RUN apk add --update ca-certificates curl \
 && apk add --update -t deps wget \
 && wget https://storage.googleapis.com/kubernetes-helm/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
 && tar -xvf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
 && mv linux-amd64/helm /usr/local/bin \
 && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
 && mv ./kubectl /usr/local/bin \
 && chmod 755 /usr/local/bin/kubectl \
 && apk del --purge deps curl \
 && rm /var/cache/apk/* \
 && rm -f /helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz

RUN helm init -c

COPY app/Makefile /cnab/app/Makefile
COPY app/charts /cnab/app/charts
COPY Dockerfile cnab/Dockerfile