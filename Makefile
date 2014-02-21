.PHONY : init clean build dist

init:
	npm install

clean:
	rm -rf lib/
	rm -f webp-*.tgz

build:
	coffee -o lib/ -c src/

dist: clean init build

pack: dist
	npm pack
