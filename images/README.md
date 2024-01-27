# infrastructure-images

Infrastructure Images are project independent docker images. The images are either built from a gcr.io base image or the github docker image is pulled and pushed to gcr.io.

## Build

The build is based mainly on docker. Only installation of Make is required.

You can get a list of all supported goals typing `make help`.

### Building specific images manually

Use `make build_ci_?` (replace ? for the name of the image, v.g. `make build_ci_dbdump`)
for building and pushing to registry a specific image manually.

### build_images_minikube

Builds images for Minikube only if they are not already available in the remote Minikube docker environment

### build_images_minikube_forced

Builds images for Minikube regardsless of any existence.

### build_images_ci

Builds images in ci environment and pushes them to eu.gcr.io.
Note: Currently not working, because Github workflow is missing.

# Images

## DBSetup

Builds a cronjob image from alpine base image and adds some logic to import the serlo database from a dump.
This image is used in Minikube as well as GCloud Dev and Staging.

## DBDump

Builds a cronjob image from alpine base image and adds some logic to save the serlo database as a dump.
This image is used in GCloud Prod to automate make the latest anonymized dump available for other envirnoments.

## Varnish

Builds a Varnish image from alpine base image.

## Grafana

Pulls and pushes the official Grafana images to gcr.io as gcr.io does not have usually the latest versions.
