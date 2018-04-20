#!/bin/bash
set -e
jq -n --arg consul_key "$(consul keygen)" --arg nomad_key "$(nomad keygen)" '{"consul_key":$consul_key,"nomad_key":$nomad_key}'
