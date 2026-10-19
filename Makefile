.DEFAULT_GOAL := help
.PHONY: help all clean

help: ## Show this help
	@awk -F':.*## ' '/^[a-z]+:.*## /{printf "  make %-8s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: ## Fetch xlsxio if missing and build the static libs into build/
	python3 build.py

clean: ## Remove build/ (keeps the fetched xlsxio/ sources)
	python3 build.py clean

