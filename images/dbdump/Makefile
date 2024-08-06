image_name=athene2-dbdump-cronjob
local_image=serlo/$(image_name)

major_version=3
minor_version=4
patch_version=3
version=$(major_version).$(minor_version).$(patch_version)

include ../docker.mk

.PHONY: docker_build
docker_build:
	docker build --build-arg version=$(version) --build-arg git_revision=$(shell git log | head -n 1 | cut  -f 2 -d ' ') -t $(local_image):$(version) .

echo-version:
	@echo $(version)
