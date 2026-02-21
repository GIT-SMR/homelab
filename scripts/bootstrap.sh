#!/usr/bin/env bash
set -e

docker network inspect edge >/dev/null 2>&1 || docker network create edge