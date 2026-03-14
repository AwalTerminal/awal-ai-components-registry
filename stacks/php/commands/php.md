# PHP Commands

## Composer
- `composer install` — install dependencies from lock file
- `composer update` — update dependencies to latest matching versions
- `composer require vendor/package` — add a dependency
- `composer require --dev vendor/package` — add a dev dependency
- `composer dump-autoload -o` — regenerate optimized autoloader

## Testing
- `./vendor/bin/phpunit` — run all tests
- `./vendor/bin/phpunit --filter=TestClassName` — run a specific test class
- `./vendor/bin/phpunit --filter=test_method_name` — run a specific test method
- `./vendor/bin/phpunit --coverage-html=coverage/` — generate HTML coverage report
- `./vendor/bin/pest` — run all tests (Pest)
- `./vendor/bin/pest --filter="creates an order"` — run matching Pest tests

## Linting and Static Analysis
- `./vendor/bin/php-cs-fixer fix` — auto-fix coding style (PSR-12)
- `./vendor/bin/php-cs-fixer fix --dry-run --diff` — preview style fixes
- `./vendor/bin/phpstan analyse` — run static analysis (PHPStan)
- `./vendor/bin/phpstan analyse --level=max` — strictest analysis level
- `./vendor/bin/psalm` — run Psalm static analysis

## Laravel
- `php artisan serve` — start development server
- `php artisan migrate` — run database migrations
- `php artisan migrate:fresh --seed` — reset database and seed
- `php artisan make:model ModelName -mfc` — create model with migration, factory, controller
- `php artisan tinker` — interactive REPL
- `php artisan test` — run tests (wraps PHPUnit/Pest)
- `php artisan test --parallel` — run tests in parallel
- `php artisan route:list` — show all registered routes
- `php artisan config:cache` — cache configuration (production)
- `php artisan queue:work` — start queue worker

## Symfony
- `php bin/console server:run` — start development server
- `php bin/console doctrine:migrations:migrate` — run migrations
- `php bin/console cache:clear` — clear cache
- `php bin/console debug:router` — list all routes

## Production
- `composer install --no-dev --optimize-autoloader` — production install
- `php artisan config:cache && php artisan route:cache && php artisan view:cache` — Laravel production caching
