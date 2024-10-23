#!/bin/bash
set -euo pipefail

if [[ ! -f env ]]; then
	echo "Run \"cp env.sample env\", set your own parameters in \"env\" and re-run this script." >&2
	exit 1
fi

source env

helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
	--create-namespace \
	--namespace buildkite \
	--set config.org="${ORGANIZATION}" \
	--set config.cluster-uuid="${CLUSTER_UUID}" \
	--set agentToken="${AGENT_TOKEN}" \
	--set graphqlToken="${GRAPHQL_TOKEN}" \
	--set "config.tags[0]=queue=default" \
	-f values.yaml
