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
	./node_modules/.bin/coffee -o lib/ -c src/
	./node_modules/.bin/coffee -o test/ -c test/
	cp -r src/*.json lib/

test: build
	@NODE_ENV=test PATH=./test/bin:${PATH} \
		./node_modules/.bin/mocha \
		--require test/utils/env \
		--reporter $(REPORTER) \
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
	@tar -tzf webp*.tgz
