#!/bin/bash

for dir in $(tree -df --noreport -i); do
	path=$(dirname "${dir}")
	stem=$(basename "${dir}")
	if [[ ${stem} =~ ^(q|adhoc|queries)$ ]]; then
		mv "${dir}" "${path}/query"
	elif [[ ${stem} =~ ^(vw|views)$ ]]; then
		mv "${dir}" "${path}/view"
	elif [ "${stem}" == "fn" ]; then
		mv "${dir}" "${path}/function"
	elif [ "${stem}" == "sp" ]; then
		mv "${dir}" "${path}/procedure"
	elif [ "${stem}" == "tr" ]; then
		mv "${dir}" "${path}/trigger"
	elif [ "${stem}" == "tbl" ]; then
		mv "${dir}" "${path}/table"
	elif [ "${stem}" == "archive" ]; then
		echo "${dir}"
	elif [[ ! ${stem} =~ ^(query|view|function|procedure|trigger|table)$ ]]; then
		echo "${dir}"
	fi
done
