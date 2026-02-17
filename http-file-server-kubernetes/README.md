# HTTP File Server
A simple file server for OpenShift, when you need to move files between hosts that have access to OpenShift.

Add:
```shell
oc project <namespace>
oc apply -f server.yaml
```

Fileserver should now be accessible from https://fileserver-<namespace>.apps.ocp.<your-domain>/

## Overview
A Kubernetes file server using copyparty (https://github.com/9001/copyparty), a portable HTTP file server with upload/download capabilities.

## Architecture

### Components Required
1. **Deployment** - Container running copyparty
2. **Service** - ClusterIP to expose the server internally
3. **Route** - OpenShift Route for external access

## Implementation Details

### Deployment Configuration
- **Container Image**: `copyparty/ac` (official Alpine-based image)
- **Storage**: Use /tmp
- **Port**: copyparty default is 3923
- **Resources**: Set appropriate CPU/memory limits

### Service Configuration
- **Type**: ClusterIP (internal access)
- **Port**: Expose port 80 (HTTP)
- **Target Port**: 3923 (container port)

### OpenShift Route Configuration
- **Service**: Points to the copyparty service
- **Port**: Target port 80
- **TLS**: edge termination
- **Host**: Auto-generated, fileserver-<namespace>.<openshift-apps-hostname>

### Storage Options
1. **Temporary (/tmp)**: Use emptyDir volume (data lost on pod restart)

### Security Considerations
No authentication, use with care!

## copyparty Configuration Options
See `Deployment.spec.template.spec.containers.args` i [server.yaml](server.yaml). Lookup help with docker:

```shell
docker run copyparty/ac:latest --help
```
