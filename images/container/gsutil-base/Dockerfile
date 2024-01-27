FROM alpine
RUN apk update && apk add bash curl python3 python3-dev py-pip build-base && rm -rf /var/cache/apk/*
RUN curl https://sdk.cloud.google.com | bash >/dev/null
ENV PATH=${PATH}:/root/google-cloud-sdk/bin:/root/google-cloud-sdk/platform/gsutil
ADD run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh
WORKDIR /tmp
CMD ["/bin/sh", "run.sh"]
ARG git_revision
ENV GIT_REVISION=$git_revision
ENV GCLOUD_BUCKET=gs://serlo_dev_terraform
ARG version
ENV VERSION $version
