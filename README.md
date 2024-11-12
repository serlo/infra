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

After changing a specific image, you should build and push it manually.  
Example:

1. `cd images/dbdump`
2. Change the version in `images/dbdump/Makefile`
3. Be sure you have already authenticated with [docker to Github Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic)
4. `make docker_build_push`

If you want to test the image just locally, use `make docker_build` in the 3rd step.
