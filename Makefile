# SHELL := /bin/bash
DB_PORT = $(shell docker inspect --format='{{(index (index .NetworkSettings.Ports "5432/tcp") 0).HostPort}}' janus_db_1)

help: ## Display help text
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) /dev/null | \
		sed 's/^[^:]*://' | sort | \
		awk -F':.*?## ' '{printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: lint help
.DEFAULT_GOAL := help

vendor/bundle: Gemfile Gemfile.lock docker/app/Dockerfile
				@ $(MAKE) bundle
				@ touch vendor/bundle

tmp/docker-build-mark: $(wildcard docker/**/*) docker-compose.yml
				docker-compose rm -f janus_db
				docker-compose pull janus_db
				docker-compose build janus_app
				@ touch tmp/docker-build-mark

config.yml:
				cp config.yml.template config.yml

composed.yml: docker-compose.yml ../metis/docker-compose.yml
				@ docker-compose -f docker-compose.yml config > /tmp/janus.yml
				@ docker-compose -f ../metis/docker-compose.yml config > /tmp/metis.yml
				@ docker-compose -f /tmp/janus.yml -f /tmp/metis.yml config > composed.yml

.PHONY: up
up: config.yml composed.yml ## Starts up the database, worker, and webservers of janus in the background.
				@ docker-compose -f composed.yml up -d

.PHONY: down
down: composed.yml ## Ends background janus processes
				@ docker-compose -f composed.yml down --remove-orphans

.PHONY: ps
ps: ## Lists status of running janus processes
				@ docker-compose -f composed.yml ps

.PHONY: bundle
bundle: ## Executes a bundle install inside of the janus app context.
				docker-compose run --rm janus_app bundle install

.PHONY: build
build: ## Rebuilds the janus docker environment.  Does not clear volumes or databases, just rebuilds code components.
				@ docker-compose -f composed.yml build

.PHONY: console
console: ## Starts an irb console inside of the janus app context.
				docker exec -ti "$$(docker ps --format '{{.Names}}' | grep janus_app)" bundle exec irb

.PHONY: migrate
migrate: ## Executes dev and test migrations inside of the janus app context.
				@ docker-compose run --rm janus_app ./bin/janus migrate
				@ docker-compose run -e JANUS_ENV=test --rm janus_app ./bin/janus migrate

.PHONY: test
test: ## Execute (all) rspec tests inside of the janus app context.
				@ docker-compose run -e JANUS_ENV=test --rm janus_app bundle exec rspec

.PHONY: bash
bash: ## Start a bash shell inside of the app context.
				@docker exec -ti "$$(docker ps --format '{{.Names}}' | grep janus_app)" bash

.PHONY: db-port
db-port: ## Print the db port associated with the app.
				@ echo $(DB_PORT)

.PHONY: psql
psql: ## Start a psql shell conntected to the janus development db
				@ PGPASSWORD=password psql -h localhost -p $(DB_PORT) -U developer -d janus_development

.PHONY: logs
logs: ## Follow logs of running containers
				docker-compose logs -f
