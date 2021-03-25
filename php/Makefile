include .env

# Default environment value
env?=dev

# Build docker images
.PHONY: build
build:
	echo "Build docker images ..."
	docker-compose build

# Start containers
.PHONY: start
start:
	echo "Start containers ..."
	docker-compose up -d

# Import database and update drupal
.PHONY: install
install:
	# ...

# Stop containers
.PHONY: stop
stop:
	echo "Stop & Remove containers ..."
	docker-compose down -v