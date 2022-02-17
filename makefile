.PHONY: docker-image docker-interactive clean

docker-image: Dockerfile
	DOCKER_BUILDKIT=1 docker build -f $< -t cloudcontrol:latest .

docker-interactive:
	docker run -v $(PWD):/home/user/host -it -w /home/user/host cloudcontrol:latest

clean:
	@echo nothing to clean.
