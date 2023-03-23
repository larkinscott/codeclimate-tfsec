.PHONY: image

IMAGE_NAME ?= codeclimate/codeclimate-tfsec

image:
	docker build --rm -t $(IMAGE_NAME) .
