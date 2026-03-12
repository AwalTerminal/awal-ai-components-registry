# Perl Test & Build

Run with prove or build tools:
- `prove -lr t/` — run all tests recursively
- `prove -lv t/specific_test.t` — run a specific test verbosely
- `perl Makefile.PL && make test` — build and test with ExtUtils::MakeMaker
- `dzil test` — run tests with Dist::Zilla
- `perlcritic lib/` — run static analysis
- `perltidy -b lib/**/*.pm` — format source files in-place
- `cpanm --installdeps .` — install dependencies from cpanfile
