TESTS = test/*.coffee
REPORTER = spec

PATH := ./node_modules/.bin:./bin:${PATH}

.PHONY: init clean build test dist pack

all: pack

init:
	npm install

clean:
	rm -rf lib/
	rm -f cwebp-*.tgz

build: clean
	coffee -o lib/ -c src/
	cp src/*.json lib/

test:
	@NODE_ENV=test PATH=./test/bin:${PATH} mocha \
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
	version
	npm publish
	@git tag `version`
	@git push origin `version`
