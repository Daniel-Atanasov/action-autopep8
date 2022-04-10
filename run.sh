#!/bin/bash

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog...'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group:: Running autopep8 with reviewdog 🐶 ...'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

autopep8_exitcode="0"
reviewdog_exitcode="0"

autopep8_output="$(autopep8 -r -i ${INPUT_AUTOPEP8_FLAGS} "${INPUT_TARGET:-.}" 2>&1)" || autopep8_exitcode="$?"

git add -A
echo "$(git diff --staged)"
echo "$(git diff --staged)" | reviewdog -name=autopep8 -f=diff -f.diff.strip=1 -diff="git diff --staged" -reporter=github-pr-review || reviewdog_exitcode="$?"
git reset
echo '::endgroup::'

# Throw error if an error occurred and fail_on_error is true
if [[ "${autopep8_exitcode}" != "0" || "${reviewdog_exitcode}" != "0" ]]; then
  exit 1
fi
