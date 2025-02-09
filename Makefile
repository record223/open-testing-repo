doc:
	@vendor/bin/sail artisan ide-helper:eloquent --ansi
	@vendor/bin/sail artisan ide-helper:generate --ansi
	@vendor/bin/sail artisan ide-helper:meta --ansi
	@vendor/bin/sail artisan ide-helper:models --write --ansi

lint:
	@vendor/bin/sail bin pint -vvv

analyse:
	@vendor/bin/sail bin phpstan analyse --memory-limit 1G  --ansi

refactor:
	@vendor/bin/sail bin rector --ansi

test:
	@vendor/bin/sail pest

pre-commit:
	@make doc
	@make refactor
	@make lint
	@make analyse
	@make test
	@echo "All checks passed. Ready to commit."

build:
	@cp .env.example .env
	@vendor/bin/sail build --no-cache
	@vendor/bin/sail up -d
	@vendor/bin/sail npm install
	@vendor/bin/sail artisan storage:unlink --ansi
	@vendor/bin/sail artisan storage:link --ansi
	@vendor/bin/sail artisan key:generate --ansi
	@vendor/bin/sail artisan migrate:install --ansi
	@vendor/bin/sail artisan migrate --force --ansi
	@vendor/bin/sail artisan db:seed --force --ansi

_pre-commit-check:
	@echo "🔍 Checking documentation generators..."
	@vendor/bin/sail artisan ide-helper:eloquent --ansi || exit 1
	@vendor/bin/sail artisan ide-helper:generate --ansi || exit 1
	@vendor/bin/sail artisan ide-helper:meta --ansi || exit 1
	@vendor/bin/sail artisan ide-helper:models --write --ansi || exit 1
	@echo "✓ Documentation checks passed"

	@echo "\n🔍 Checking code quality with Rector..."
	@vendor/bin/sail bin rector --dry-run --ansi || exit 1
	@echo "✓ Rector checks passed"

	@echo "\n🔍 Running PHP linting..."
	@vendor/bin/sail bin pint --test -vvv || exit 1
	@echo "✓ PHP lint checks passed"

	@echo "\n🔍 Checking code formatting..."
	@vendor/bin/sail npm run format:check || exit 1
	@echo "✓ Code formatting checks passed"

	@echo "\n🔍 Running JS/TS linting..."
	@vendor/bin/sail npm run lint:check || exit 1
	@echo "✓ JS/TS lint checks passed"

	@echo "\n🔍 Running static analysis..."
	@vendor/bin/sail bin phpstan analyse --ansi || exit 1
	@echo "✓ Static analysis passed"

	@echo "\n🔍 Checking if frontend builds correctly..."
	@vendor/bin/sail npm run build || exit 1
	@echo "✓ Frontend build checks passed"

	@echo "\n🔍 Running tests..."
	@vendor/bin/sail artisan test --ansi || exit 1
	@vendor/bin/sail npm run test || exit 1
	@echo "✓ All tests passed"

	@echo "\n✨ All checks completed successfully! You can commit your changes."
