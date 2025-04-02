BENCHMARKS_PATH := ./benchmarks

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+%?:.*?## .*$$' $(MAKEFILE_LIST) | sed 's/^*://g' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: install-benchi
install-benchi: ## Install latest version of benchi.
	curl -s https://raw.githubusercontent.com/ConduitIO/benchi/main/install.sh | sh

.PHONY: list
list: ## List all benchmarks.
	@find ${BENCHMARKS_PATH} -name benchi.yml | xargs -I {} dirname {} | xargs -I {} basename {}

.PHONY: ls
ls: list

.PHONY: run-all
run-all: ## Run all benchmarks. Optionally add "run-<benchmark-name>" to run a specific benchmark.
	@find ${BENCHMARKS_PATH} -name benchi.yml | xargs -I {} benchi -config {}

run-%: ## Run a specific benchmark.
	@find ${BENCHMARKS_PATH}/$* -name benchi.yml | xargs -I {} benchi -config {}

.PHONY: rmi-conduit
rmi-conduit: ## Remove the Conduit docker image (use when built-in connectors get added or upgraded).
	docker rmi benchi/conduit
