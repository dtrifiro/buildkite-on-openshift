#!/bin/bash
set -euo pipefail

if [[ ! -f env ]]; then
	echo "Run \"cp env.sample env\", set your own parameters in \"env\" and re-run this script." >&2
	exit 1
fi

source env

export AGENT_TOKEN=rRxxLdcZpA4jTCYaERE9NHKi
export GRAPHQL_TOKEN=bkua_e89904377fa7781750b89c620177cf2938daf7ba
export ORGANIZATION=dtrifiro-testing
export CLUSTER_UUID=1d4c27a6-ae3c-4e11-bec8-c154e555c769

helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
	--create-namespace \
	--namespace buildkite \
	--set config.org="${ORGANIZATION}" \
	--set config.cluster-uuid="${CLUSTER_UUID}" \
	--set agentToken="${AGENT_TOKEN}" \
	--set graphqlToken="${GRAPHQL_TOKEN}" \
	--set "config.tags[0]=queue=default" \
	-f values.yaml
