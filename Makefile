RAILS_ENV ?= development
COMPOSE_PROJECT_NAME := chotto-jigsaw
COMPOSE_COMMAND := docker-compose


guard:
	@eval "$(shell $(MAKE) envs)" && bundle exec guard
.PHONY: guard

infra-up:
	${COMPOSE_COMMAND} up -d
	@bundle exec spring stop
	$$($(MAKE) --no-print-directory envs) && rails db:setup || rails db:migrate
.PHONY: infra-up

infra-down:
	${COMPOSE_COMMAND} down
	@bundle exec spring stop
.PHONY: infra-down

rails-update:
	$$($(MAKE) --no-print-directory envs) && bin/update
.PHONY: rails-update

envs: DB_CONTAINER := $(shell docker ps -q --filter 'name=${COMPOSE_PROJECT_NAME}_db_*')
envs: DB_PORT := $(shell docker port ${DB_CONTAINER} | cut -d ':' -f 2)
envs:
	@echo "export DB_PORT=${DB_PORT}"
.PHONY: env

rails-console:
	@eval "$(shell $(MAKE) envs)" && rails console
.PHONY: rails-console

db-console:
	@eval "$(shell $(MAKE) envs)" && psql -U postgres -h localhost -p $$DB_PORT -d timecard_kun_${RAILS_ENV}
.PHONY: db-console
