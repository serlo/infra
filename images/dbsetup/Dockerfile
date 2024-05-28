FROM alpine:3.17.2

RUN apk update && apk add bash curl python3 python3-dev py-pip build-base && rm -rf /var/cache/apk/*
RUN curl https://sdk.cloud.google.com | bash >/dev/null
ENV PATH=${PATH}:/root/google-cloud-sdk/bin:/root/google-cloud-sdk/platform/gsutil
RUN apk update && apk add mysql-client postgresql-client unzip && rm -rf /var/cache/apk/*

WORKDIR /tmp
COPY . .

ARG git_revision
ENV GIT_REVISION=$git_revision
ARG version
ENV VERSION $version

CMD ["./run.sh"]
