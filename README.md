# How to run buildkite runner on OpenShift

## Requirements

- `helm` the kubernetes package manager https://github.com/helm/helm
- an account on buildkite.com

## Install steps

1. Create a new organization on buildkite.com
2. On the main buildkite page:
   - Click "Agents" and then "skip"
   - Create a new cluster
   - Click Agent tokens
   - Create new agent token and copy it
3. Create a new token for the given organization on https://buildkite.com/user/api-access-tokens/new (make sure to enable GraphQL at the bottom of the page)
4. Create an `env` file from the template and set the required values:

```bash
cp env.sample env
$EDITOR env
# and set:
export ORGANIZATION=<your org name> # change as needed
export AGENT_TOKEN=<token>  # replace as needed
export GRAPHQL_TOKEN=<token> # replace with token created in step 2
export CLUSTER_UUID=<cluster uuid> # get this from https://buildkite.com/organizations/<YOUR_USERNAME>/clusters/
```

6. [Only required on OpenShift] Create the configmap to override environment variables of created pods (see OpenShift Notes below):

```bash
kubectl apply -f configmap.yaml
```

6. You can now install `agent-stack-k8s` with:

```bash
bash install.sh
```

7. On the buildkite site, click `Pipelines` and select "New pipeline"
   - Select the github user/organization, allow access to the buildkite github app if required
   - add any env vars if required
   - Select the cluster created on step 2
   - Select the script to run in the given repo (or add a custom command)
   - Click "Create pipeline"
8. Click on configure github webhooks to set up webhooks
9. Everything should be set up, click "Run build to verify that it works"

## OpenShift Notes

OpenShift does not allow containers to run as root by default, meaning some containers can have permissions issue.

In the case of agent stack k8s, when setting up a job's pod, buildkite attempts to create `$HOME/.buildkite-agent` directory where some temporary files/sockets are stored. Since `$HOME` is not set, this is created in `/`, which results in an error if the user is not root.

There are two solutions to fix this:

### Configmap override:

Creating a ConfigMap that sets the `HOME` env var to a location to which the user can write to (e.g. `/tmp`) and using it in the `default-checkout-params` section of the config:

```yaml
# # Applies to the checkout container in all spawned pods
default-checkout-params:
  envFrom:
    - configMapRef:
        name: agent-stack-k8s-env-vars-config
```

```bash
kubectl apply -f configmap.yaml
```

### SCC override (not recommended)

The `anyuid` [scc](https://docs.openshift.com/container-platform/latest/authentication/managing-security-context-constraints.html) can be used to allow users to run with any UID and GID.

For example, to add the `anyuid` scc to a specific user or group:

```bash
oc adm policy add-scc-to-user anyuid dtrifiro@redhat.com
# or to a group:
oc adm polciy add-scc-to-group anyuid <group name>
```

## Reference

- https://github.com/buildkite/agent-stack-k8s
