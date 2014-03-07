TESTS = test/*.js
REPORTER = spec

PATH := ./node_modules/.bin:${PATH}

.PHONY: init clean build test dist pack

init:
	npm install

clean:
	rm -rf lib/
	rm -rf test/*.js
	rm -f cwebp-*.tgz

build: clean
	coffee -o lib/ -c src/
	coffee -o test/ -c test/
	cp -r src/*.json lib/

test: build
	@NODE_ENV=test PATH=./test/bin:${PATH} mocha \
		--require test/utils/env \
		--reporter $(REPORTER) \
		--growl \
		--slow 250 \
		$(TESTS)

validate: build
	@./test/bin/validate

dist: init build test

pack: dist
	@echo "PACKAGE:"
	@npm pack
	@echo ""
	@echo "FILES:"
	@tar -tzf cwebp*.tgz

publish: dist
	npm publish
