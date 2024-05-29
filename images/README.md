# infrastructure-images

Infrastructure Images are GC-project independent docker images.

## Requirements

Docker and Make

### Building and pushing images

After changing a specific image, you should build and push it manually.  
Example:

1. `cd images/dbdump`
2. Change the version in `images/dbdump/Makefile`
3. `make docker_build_push`

If you want to test the image just locally, use `make docker_build` in the 3rd step.

# Images

## DBDump

Builds a cronjob image to save the serlo database as an anonymized dump.

## DBSetup

Builds a cronjob image to import the serlo database from the dump.
