image_name=athene2-dbdump-cronjob
local_image=serlo/$(image_name)

# change version if you want to push a new image
major_version=3
minor_version=4
patch_version=1
version=$(major_version).$(minor_version).$(patch_version)

include ../../mk/dockerci.mk

.PHONY: docker_build
docker_build:
	docker build --build-arg version=$(version) --build-arg git_revision=$(shell git log | head -n 1 | cut  -f 2 -d ' ') -t $(local_image) .
