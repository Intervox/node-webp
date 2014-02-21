TESTS = test/*.js
REPORTER = spec

.PHONY: init clean build test dist pack

init:
	npm install

clean:
	rm -rf lib/
	rm -rf test/*.js
	rm -f webp-*.tgz

build: clean
	coffee -o lib/ -c src/
	coffee -o test/ -c test/

test: build
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--require should \
		--reporter $(REPORTER) \
		--compilers coffee:coffee-script \
		$(TESTS)

dist: init build test

pack: dist
	npm pack
