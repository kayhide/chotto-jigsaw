RAILS_ENV ?= development
COMPOSE_PROJECT_NAME := $(shell basename $(shell pwd))
COMPOSE_COMMAND := docker-compose


dev:
	docker-compose up -d entrance-dev worker livereload firestore
	@$$($(MAKE) --no-print-directory envs)
.PHONY: dev

guard:
	docker-compose up -d firestore
	docker-compose run --rm runner bash -c "cd rails; guard --plugin RSpec"
.PHONY: guard

setup:
	docker-compose run --rm -e "SEED_USERS=${SEED_USERS}" runner setup
.PHONY: setup

down:
	docker-compose down
.PHONY: down

provision:
	${COMPOSE_COMMAND} up -d db redis firestore
	@$$($(MAKE) --no-print-directory envs)
.PHONY: provision

unprovision:
	${COMPOSE_COMMAND} down
	@$$($(MAKE) --no-print-directory envs)
.PHONY: unprovision

envs: DB_PORT := $(shell docker-compose port db 5432 | cut -d ':' -f 2)
envs: REDIS_PORT := $(shell docker-compose port redis 6379 | cut -d ':' -f 2)
envs: FIRESTORE_PORT := $(shell docker-compose port firestore 8080 | cut -d ':' -f 2)
envs:
	@mkdir -p .env
	@echo "${DB_PORT}" > .env/DB_PORT 
	@echo "${REDIS_PORT}" > .env/REDIS_PORT
	@echo "${FIRESTORE_PORT}" > .env/FIRESTORE_PORT
.PHONY: envs
