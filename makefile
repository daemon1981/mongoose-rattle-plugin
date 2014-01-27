REPORTER = dot

check: test

test:
	@NODE_ENV=test ./node_modules/.bin/mocha $(T) \
		--compilers coffee:coffee-script \
		--recursive \
		--reporter $(REPORTER) \
		test/unit

test-report:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		--recursive \
		--reporter markdown \
		test/unit > ./test-unit.md

.PHONY: test test-report
