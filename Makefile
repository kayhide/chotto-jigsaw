RAILS_ENV ?= development
COMPOSE_PROJECT_NAME := $(shell basename $(shell pwd))
COMPOSE_COMMAND := docker-compose


dev:
	@hivemind $${PORT:+--port $$PORT} --port-step 1 Procfile.dev
.PHONY: dev

guard:
	@bin/bundle exec guard --plugin RSpec
.PHONY: guard

provision:
	${COMPOSE_COMMAND} up -d
	@bin/spring stop
	@$$($(MAKE) --no-print-directory envs) \
	&& (bin/rails db:migrate 2> /dev/null) || bin/rails db:setup
.PHONY: provision

unprovision:
	${COMPOSE_COMMAND} down
	@bin/spring stop
.PHONY: unprovision

envs:
	$(eval DB_CONTAINER := $(shell docker ps -q --filter 'name=${COMPOSE_PROJECT_NAME}_db_*'))
	$(eval DB_PORT := $(shell docker port ${DB_CONTAINER} | cut -d ':' -f 2))
	@echo "export DB_PORT=${DB_PORT}"
.PHONY: envs
