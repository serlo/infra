# infrastructure-images

Infrastructure Images are GC-project independent docker images.

## Requirements

Docker and Make

### Building images

After changing a specific image, you should build it manually.  
Example:

1. `cd images/dbdump`
2. Change the version in `images/dbdump/Makefile`
3. `make docker_build`

# Images

## DBDump

Builds a cronjob image to save the serlo database as an anonymized dump.

## DBSetup

Builds a cronjob image to import the serlo database from the dump.
