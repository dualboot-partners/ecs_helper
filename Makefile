.PHONY: test build bump-major bump-minor bump-patch help
.DEFAULT_GOAL := test
CURRENT_VERSION=$(shell bump current)
NEXT_PATCH=$(shell bump show-next patch)
NEXT_MINOR=$(shell bump show-next minor)
NEXT_MAJOR=$(shell bump show-next major)
GEM_VERSION=ecs_helper-${CURRENT_VERSION}.gem

test: ## Run the unit tests
	bundle exec rake --trace

build: ## Build the ruby gem
	gem build ecs_helper.gemspec

push:
	gem push ${GEM_VERSION}

release:
	bump set ${NEXT_PATCH}
	make build
	make push

bump-major: ## Bump the major version (1.0.0 -> 2.0.0)
	bump major

bump-minor: ## Bump the minor version (0.1.0 -> 0.2.0)
	bump minor

bump-patch: ## Bump the patch version (0.0.1 -> 0.0.2)
	bump patch
