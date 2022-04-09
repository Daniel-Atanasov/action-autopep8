#!/bin/bash

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog...'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- 2>&1
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group:: Running autopep8 with reviewdog 🐶 ...'
autopep8_exitcode="0"
reviewdog_exitcode="0"

autopep8_output="$(autopep8 -r -d ${INPUT_AUTOPEP8_FLAGS} "${INPUT_TARGET:-.}" 2>&1)" || autopep8_exitcode="$?"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"
echo "${autopep8_output}" | reviewdog -f=diff -reporter=github-pr-check || reviewdog_exitcode="$?"
echo '::endgroup::'

# Throw error if an error occurred and fail_on_error is true
if [[ "${autopep8_exitcode}" != "0" || "${reviewdog_exitcode}" != "0" ]]; then
  exit 1
fi
