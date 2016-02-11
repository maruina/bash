#!/bin/bash

#!/bin/bash
set -e
set -u
top_pid="$$"


# Check commands
git=$(command -v git)
tee=$(command -v tee)


# Set the logging
out_file=/tmp/packer-provision.out
err_file=/tmp/packer-provision.err
exec > >("${tee}" "${out_file}")
exec 2> >("${tee}" "${err_file}")


# Variables declarations
start_time=$(date +%s)


# Common function declarations
_log () {
    echo "${instance_id}: ${1}" | curl -s -d @- "${log_url}" > /dev/null
}

_msg () {
    printf "\033[1m${1}\033[0m\n"
    _log "${1}"
}

_die () {
    printf "\033[1;31m${1}\033[0m\n"
    _log "${1}"
    send_slack_message "${1}"
    # Kill the main process
    kill -s TERM "${top_pid}"
}


send_slack_message () {
    local -i ret=0
    local emoji=":snake:"
    local channel="#packer-builds"
    local username="Packer-Snake"
    local payload="{\"channel\": \""${channel}"\", \"username\": \""${username}"\", \"text\": \"*FAILURE* in creating a new version of *"${SERVICE_NAME}"* because of "${1}"\", \"icon_emoji\": \""${emoji}"\"}"

    "${curl}" --silent -X POST --data-urlencode payload="${payload}" https://hooks.slack.com/services/TOKEN || ret="${?}"
    if [[ "${ret}" -ne 0 ]]; then
        _msg "ERROR: cannot send message to slack"
        exit 1
    fi
}
