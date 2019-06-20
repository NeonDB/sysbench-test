#!/bin/bash

# LOG {LEVEL} {MESSAGE}
function LOG() {
    typeset filename=$(basename ${BASH_SOURCE[2]})
    typeset lineno=${BASH_LINENO[1]}
    typeset funcname=${FUNCNAME[2]}
    typeset loglevel=${1}
    shift 1

    # check whether log-level is set correctly
    passlevel ${loglevel}
    if [ $? -eq 0 ]; then
       printf "$(date +'%Y-%m-%d %H:%M:%S') [${filename}:${funcname}:${lineno}] ${loglevel}: ${*}\n" 1>&2
    fi
}

function TRACE() {
    LOG "TRACE" "${*}"
}

function DEBUG() {
    LOG "DEBUG" "${*}"
}

function INFO() {
    LOG "INFO " "${*}"
}


function WARN() {
    LOG "WARN " "${*}"
}

function ERROR() {
    LOG "ERROR" "${*}"
}

function ENTRY() {
    LOG "ENTRY" "${*}"
}

# RETURN from function
# {1} optional return value, if not provide, return last command return value
# {2} optional exit message
# Notice: since there is no way return from parent function directly, this RETURN function will not returned from caller; so it's suggest for caller to use this function like:
#  RETURN [retvalue [retmessage]] ; return $?
# i.e., use a explicit return directly after RETURN
function RETURN() {
    typeset ret=$?
    if [ $# -gt 0 ]; then
        ret=${1}
        shift 1
    fi
    LOG "RETURN" "${*}"
    return ${ret}
}

# EXIT from program directly
# {1} optional return value, if not provide, return last command return value
# {2} optional exit message
function EXIT() {
    typeset ret=$?
    if [ $# -gt 0 ]; then
        ret=${1}
        shift 1
    fi
    LOG "EXIT" "${*}"
    exit ${ret}
}

function passlevel() {
    typeset V_LOGLEVEL=${LOGLEVEL:-INFO}
    case ${1} in
        TRACE)             if [[ "${V_LOGLEVEL}" =~ ^(TRACE) ]]; then return 0; fi ;;
        DEBUG)             if [[ "${V_LOGLEVEL}" =~ ^(TRACE|DEBUG) ]]; then return 0; fi ;;
        ENTRY|RETURN|EXIT) if [[ "${V_LOGLEVEL}" =~ ^(TRACE|DEBUG|ENTRY|RETURN|EXIT) ]]; then return 0; fi ;;
        INFO)              if [[ "${V_LOGLEVEL}" =~ ^(TRACE|DEBUG|ENTRY|RETURN|EXIT|INFO) ]]; then return 0; fi ;;
        WARN)              if [[ "${V_LOGLEVEL}" =~ ^(TRACE|DEBUG|ENTRY|RETURN|EXIT|INFO|WARN) ]]; then return 0; fi ;;
        ERROR)             if [[ "${V_LOGLEVEL}" =~ ^(TRACE|DEBUG|ENTRY|RETURN|EXIT|INFO|WARN|ERROR) ]]; then return 0; fi ;;
    esac
    return 1
}

#declare -fx LOG
#declare -fx TRACE
#declare -fx DEBUG
#declare -fx INFO
#declare -fx WARN
#declare -fx ERROR