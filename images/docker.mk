#
# goals required for continous integration builds that push to gcr.io
#

ifeq ($(image_name),)
$(error image_name not defined)
endif

ifeq ($(version),)
$(error version not defined)
endif

ifeq ($(major_version),)
$(error major_version not defined)
endif

ifeq ($(minor_version),)
$(error minor_version not defined)
endif

remote_image_name := ghcr.io/serlo/infra/$(image_name)

patch_version ?= $(shell git log --pretty=format:'' | wc -l)

.PHONY: docker_build
docker_build:
	docker build --build-arg version=$(version) --build-arg git_revision=$(shell git log | head -n 1 | cut  -f 2 -d ' ') -t $(image_name):$(version) .

.PHONY: docker_build_push
docker_build_push:
	 docker pull $(remote_image_name):$(version) 2>/dev/null >/dev/null || $(MAKE) docker_build docker_push

.PHONY: docker_push
docker_push:
	docker tag $(image_name):$(version) $(remote_image_name):$(version)
	docker push $(remote_image_name):$(version)
