FROM alpine:3.7

RUN apk add --update ca-certificates \
# && apk del --purge deps \
 && rm /var/cache/apk/*

COPY Dockerfile /cnab/Dockerfile
COPY app/armup /cnab/app/armup
COPY app/arm /cnab/app/arm
COPY app/run /cnab/app/run

RUN chmod 755 /cnab/app/run /cnab/app/armup

CMD ["/cnab/app/run"]