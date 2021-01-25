## Setup Cluster

1.  Use SSH keys without passphrase

1.  [Get RKE binary](https://rancher.com/docs/rke/latest/en/installation/#download-the-rke-binary) and add it into `$PATH`

1.  Configure cluster by running `rke config --name cluster.yml`

1.  Make sure there's is one non-loopback nameserver address in `/etc/resolv.conf` (consult to docs of your OS)

1.  Deploy cluster

## Bootstrapping

    export KUBECONFIG=$PWD/kube_config_cluster.yml
    kubectl apply -f bootstrap.yml

## Deploying Containers

### Config

1.  Go to `config` directory:

        cd config

1.  Create `generate.json` to define parameters for generating new config and secret:

    Example:

        {
            "hostname": "demoexample.jans.io",
            "country_code": "US",
            "state": "TX",
            "city": "Austin",
            "admin_pw": "S3cr3t+pass",
            "ldap_pw": "S3cr3t+pass",
            "email": "s@jans.local",
            "org_name": "Janssen Project"
        }

    Afterwards, save this file into ConfigMaps:

        kubectl -n jans create cm config-generate-params --from-file=generate.json

1.  Load config and secret:

        kubectl apply -f config-load.yaml

### WrenDS (LDAP)

1.  Go to `ldap` directory:

        cd ../ldap

1.  Deploy OpenDJ pod that generates initial data:

        kubectl apply -f opendj.yaml

## Persistence Data

1.  Go to `persistence` directory:

        cd ../persistence

1.  Deploy OpenDJ pod that generates initial data:

        kubectl apply -f persistence.yaml

    This will create job to inject data to LDAP.

### nginx Ingress

1.  To allow external traffic to the cluster, we need to deploy nginx Ingress and its controller.

        cd ../nginx

1.  Create secrets to store TLS cert and key:

        sh tls-secrets.sh

1.  Afterwards deploy the custom Ingress for Janssen Server routes.

        kubectl apply -f nginx.yaml

### auth

1.  Go to `auth` directory:

        cd ../auth

1.  Deploy `jans-auth` pod:

        NGINX_IP=$HOST_IP sh deploy-pod.sh

## Scaling Containers

To scale containers, run the following command:

    kubectl -n jans scale --replicas=<number> <resource> <name>

In this case, `<resource>` could be Deployment or Statefulset and `<name>` is the resource name.

Examples:

-   Scaling `jans-auth`:

        kubectl -n jans scale --replicas=2 deployment jans-auth
