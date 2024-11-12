# Infrastructure for Serlo

Serlo Infrastructure currently runs on Google Cloud and Cloudflare.

## Environments

We support the following environments:

1. **https://serlo-staging.dev** (staging environment to test and integrate infrastructure and apps)
2. **https://serlo.org** (production environment)

### Requirements

Terraform and Kubernetes

### Deployment process

The infrastructure unit deploys the code. As open source contributor, please open a pull request.

## Images

- DBDump: a cronjob to save the serlo database as an anonymized dump.
- DBSetup: cronjob to import the serlo database from the dump.

### Requirements

Docker and Make

### Building and pushing images

If you want to test the image just locally, use `make docker_build`.
To publish an image just push to any branch after changing a version, and the CI is gone take care of it.
