image_name="varnish"
local_image=serlo/$(image_name)

major_version=6
minor_version=0
patch_version=2
version=$(major_version).$(minor_version).$(patch_version) 

include ../../mk/dockerci.mk

.PHONY: docker_build
# build the docker container
docker_build:
	docker build --build-arg version=$(version) --build-arg git_revision=$(shell git log | head -n 1 | cut  -f 2 -d ' ') -t $(local_image) .

