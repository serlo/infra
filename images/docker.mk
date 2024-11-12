#
# goals required for continous integration builds that push to gcr.io
#

ifeq ($(image_name),)
$(error image_name not defined)
endif

ifeq ($(version),)
$(error version not defined)
endif

ifeq ($(local_image),)
$(error local_image not defined)
endif

ifeq ($(major_version),)
$(error major_version not defined)
endif

ifeq ($(minor_version),)
$(error minor_version not defined)
endif

image_name := ghcr.io/serlo/infra/$(image_name)

patch_version ?= $(shell git log --pretty=format:'' | wc -l)

.PHONY: docker_build_push
docker_build_push:
	 docker pull $(image_name):$(version) 2>/dev/null >/dev/null || $(MAKE) docker_build docker_push

.PHONY: docker_push
docker_push:
	docker tag $(local_image):latest $(image_name):latest
	docker push $(image_name):latest
	docker tag $(local_image):latest $(image_name):$(major_version)
	docker push $(image_name):$(major_version)
	docker tag $(local_image):latest $(image_name):$(major_version).$(minor_version)
	docker push $(image_name):$(major_version).$(minor_version)
	docker tag $(local_image):latest $(image_name):$(version)
	docker push $(image_name):$(version)
	docker tag $(local_image):latest $(image_name):sha-$(shell git describe --dirty --always)
	docker push $(image_name):sha-$(shell git describe --dirty --always)
