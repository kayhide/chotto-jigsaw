RAILS_ENV ?= development
COMPOSE_PROJECT_NAME := $(shell basename $(shell pwd))
COMPOSE_COMMAND := docker-compose


dev:
	mutagen project terminate
	mutagen project start
	docker-compose up -d web worker livereload webpacker
.PHONY: dev

guard:
	docker-compose run --rm runner guard --plugin RSpec
.PHONY: guard

setup:
	docker-compose run --rm -e "SEED_USERS=${SEED_USERS}" runner setup
.PHONY: setup
