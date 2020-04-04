RAILS_ENV ?= development
COMPOSE_PROJECT_NAME := $(shell basename $(shell pwd))
COMPOSE_COMMAND := docker-compose


dev:
	docker-compose up -d web worker livereload frontend-dev
.PHONY: dev

guard:
	docker-compose run --rm runner guard --plugin RSpec
.PHONY: guard

setup:
	docker-compose run --rm -e "SEED_USERS=${SEED_USERS}" runner setup
.PHONY: setup


provision:
	${COMPOSE_COMMAND} up -d db redis
	@$$($(MAKE) --no-print-directory envs)
	@bin/spring stop
.PHONY: provision

unprovision:
	${COMPOSE_COMMAND} down
	@bin/spring stop
.PHONY: unprovision

envs: DB_PORT := $(shell docker-compose port db 5432 | cut -d ':' -f 2)
envs: REDIS_PORT := $(shell docker-compose port redis 6379 | cut -d ':' -f 2)
envs:
	@mkdir -p .env
	@rm -f .env/ports
	@echo "export DB_PORT=${DB_PORT}" >> .env/ports
	@echo "export REDIS_PORT=${REDIS_PORT}" >> .env/ports
.PHONY: envs
