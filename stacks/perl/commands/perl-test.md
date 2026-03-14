# Perl Test & Build Commands

## Running Tests

- `prove -lr t/` — run all tests recursively with lib in @INC
- `prove -lv t/` — verbose output showing each test
- `prove -lv t/specific_test.t` — run a single test file
- `prove -lr --jobs 4 t/` — run tests in parallel
- `prove -lr --state=failed t/` — re-run only previously failed tests
- `prove -lr --timer t/` — show timing for each test

## Building

- `perl Makefile.PL && make` — build with ExtUtils::MakeMaker
- `perl Makefile.PL && make test` — build and run tests
- `perl Build.PL && ./Build && ./Build test` — build with Module::Build
- `dzil build` — build distribution with Dist::Zilla
- `dzil test` — run tests with Dist::Zilla
- `dzil release` — release to CPAN

## Linting and Formatting

- `perlcritic lib/` — run static analysis (default severity 5)
- `perlcritic --severity 4 lib/` — stricter analysis
- `perlcritic --profile .perlcriticrc lib/` — use project config
- `perltidy -b lib/**/*.pm` — format source files in-place (backup originals)
- `perltidy -st lib/MyApp.pm | diff lib/MyApp.pm -` — preview formatting changes

## Dependency Management

- `cpanm --installdeps .` — install dependencies from cpanfile
- `cpanm --installdeps --with-develop .` — include development dependencies
- `cpanm Module::Name` — install a specific module
- `cpanm --look Module::Name` — download and open module source for inspection
- `carton install` — install exact versions from cpanfile.snapshot

## Debugging

- `perl -d script.pl` — run with built-in debugger
- `perl -c lib/MyApp.pm` — syntax check without running
- `perl -MO=Deparse script.pl` — show how Perl interprets the code
- `perl -MDevel::NYTProf script.pl && nytprofhtml` — profile and generate HTML report

## CPAN Tooling

- `cpan-upload MyApp-0.01.tar.gz` — upload to CPAN
- `cpanm --info Module::Name` — show module info
- `corelist Module::Name` — check if module is in core
- `perldoc Module::Name` — view module documentation
