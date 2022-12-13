#!/bin/bash

shopt -s globstar nullglob
for file in **/*.sql; do
	path=$(dirname "${file}")
	schema="${path%/*}"

	stem=$(basename "${file}")
	new_stem="${stem#*_"${schema}".}"

	mv "${file}" "${path}/${new_stem}"
done
