#!/usr/bin/env bash

dockerimage="openbridge/ob_google-bigquery"
args=("$@")


function mode() {

  if [[ ${args[0]} = "prod" ]]; then MODE="prod" && export MODE=${1}; else export MODE="test"; fi
  if [[ -z ${args[1]} ]]; then START=$(date -d "1 day ago" "+%Y-%m-%d"); else START="${args[1]}" && echo "OK: START date passed... "; fi
  if [[ -z ${args[2]} ]]; then END=$(date -d "1 day ago" "+%Y-%m-%d"); else END="${args[2]}" && echo "OK: END date passed... "; fi

}

function process() {

  for i in ./env/prod/*.env; do
    echo "working on $i"
    bash -c "docker run -it -v /Users/thomas/Documents/github/ob_google-cloud/auth/prod/prod.json:/auth.json -v /Users/thomas/Documents/github/ob_google-cloud/sql:/sql --env-file ${i} ${dockerimage} bigquery-run ${MODE} ${START} ${END}"
    if [[ $? = 0 ]]; then echo "OK: "; else echo "ERROR: "; fi
  done
}

function run() {

  mode "$@"
  process
  echo "OK: All processes have completed."

}

run "$@"

exit 0
