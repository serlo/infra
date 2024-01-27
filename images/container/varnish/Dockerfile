FROM alpine:3.8

EXPOSE 80

RUN apk update && \
    apk upgrade && \
    apk add varnish jq && \
    apk --no-cache add procps && \
    rm -rf /var/cache/apk/*

ENV VARNISH_MEMORY 100M
ENV VARNISH_CONFIG_FILE /etc/varnish/default.vcl

ADD start.sh /tmp/start.sh
ADD default.vcl /etc/varnish/default.vcl
RUN chmod +x /tmp/start.sh

ARG version
ENV VERSION $version

ARG git_revision
ENV GIT_REVISION $git_revision

CMD ["/tmp/start.sh"]
