FROM alpine:3.17.2

RUN apk update
RUN apk add bash curl python3 python3-dev py-pip build-base mysql-client postgresql zip
RUN rm -rf /var/cache/apk/*

RUN mkdir /run/postgresql
RUN chown postgres:postgres /run/postgresql/

USER postgres

# make a local postgres server to securely and easily manipulate data before dumping
RUN mkdir /var/lib/postgresql/data
RUN chmod 0700 /var/lib/postgresql/data
RUN initdb -D /var/lib/postgresql/data
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf
RUN echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf

RUN curl https://sdk.cloud.google.com | bash >/dev/null
ENV PATH=${PATH}:/var/lib/postgresql/google-cloud-sdk/bin:/var/lib/postgresql/google-cloud-sdk/platform/gsutil

WORKDIR /tmp
COPY . .

ARG git_revision
ENV GIT_REVISION=$git_revision
ARG version
ENV VERSION=$version

CMD ["./run.sh"]
