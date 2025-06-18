format: ## Format code
	@echo "Formatting code..."
	@dart format .

format-check: ## Check code formatting
	@echo "Checking code formatting..."
	@dart format --set-exit-if-changed .

fix: ## Apply automated fixes
	@echo "Applying automated fixes..."
	@dart fix --apply
	@dart format .

publish: ## Dry run package publishing
	@echo "Performing dry run..."
	@dart pub publish --dry-run