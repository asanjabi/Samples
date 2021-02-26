#! /bin/bash
set -euxo pipefail

az deployment sub create -l westus -f ./main.json -p adminPrincipalId=$groupObjectId
