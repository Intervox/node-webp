TESTS = test/*.coffee
REPORTER = spec

PATH := ./node_modules/.bin:./bin:${PATH}

.PHONY: init install clean build test dist pack publish

all: pack

init:
	npm install

install:
	@./bin/install_webp

clean:
	rm -rf lib/
	rm -f cwebp-*.tgz

build: clean
	coffee -o lib/ -cb src/
	cp src/*.json lib/

test:
	@NODE_ENV=test mocha \
		--compilers coffee:coffee-script/register \
		--require test/utils/env \
		--reporter $(REPORTER) \
		--growl \
		--slow 250 \
		$(TESTS)

dist: init test build

pack: dist
	@echo "\nPACKAGE:"
	@npm pack
	@echo "\nFILES:"
	@tar -tzf cwebp*.tgz

publish: dist
	npm publish
	@git push origin +HEAD:latest --follow-tags
