SHELL := /bin/bash

clean:
	rm -f ./package-lock.json \
	&& rm -rf ./node_modules \
	&& rm -rf ./.cache \
	&& rm -f ./public/assets/* \
	&& rm -f ./svelte/package-lock.json \
	&& rm -rf ./svelte/node_modules \
	&& rm -rf ./svelte/dist

run:
	npm install \
	&& node server.js

deploy:
	make clean \
	&& flyctl deploy

build:
	pushd svelte \
	&& npm install \
	&& npm run build \
	&& popd \
	&& rm -f ./public/assets/* \
	&& cp ./svelte/dist/assets/* ./public/assets/
