image_name=grafana
version=6.2.5
local_image=grafana/$(image_name)
gce_image=eu.gcr.io/serlo-shared/$(image_name)


.PHONY: docker_build_ci
# builds the docker image in the ci and pushes it to eu.gcr.io
docker_build_ci:
	 docker pull eu.gcr.io/serlo-shared/${image_name}:$(version) 2>/dev/null >/dev/null || $(MAKE) docker_push

.PHONY: docker_push_ci
# push grafana image to gcr.io
docker_push_ci:
	docker pull $(local_image):$(version)
	docker tag $(local_image):$(version) $(gce_image):$(version);
	docker push $(gce_image):$(version)
	docker tag $(local_image):$(version) $(gce_image):latest;
	docker push $(gce_image):latest

.PHONY: docker_build_minikube
# checks if the docker images is in the remote docker and builds it if not
docker_build_minikube:
	@echo nothing to do minikube pulls grafana from github


docker_build:
	@echo nothing to do we take grafana from github

