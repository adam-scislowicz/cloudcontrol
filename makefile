.PHONY: docker-image docker-interactive clean

docker-image: Dockerfile
	GID=$(shell id -g) DOCKER_BUILDKIT=1 docker build -f $< -t cloudcontrol:latest .

docker-interactive:
	docker run -v $(PWD):/home/$(USER)/cloudcontrol -it -w /home/$(USER)/cloudcontrol cloudcontrol:latest

clean:
	@echo nothing to clean.
