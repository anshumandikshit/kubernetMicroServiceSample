🧠 MicroK8s + WSL2: Fixing Calico & Ingress Controller Issues
🔧 Problem
- calico-node stuck in Init:CreateContainerError
- calico-kube-controllers in CrashLoopBackOff
- nginx-ingress-microk8s-controller stuck at READY 0/1
- Root cause: WSL2 mount propagation blocks Calico’s mount-bpffs init container

✅ Fix Steps
1. Patch Calico DaemonSet
kubectl get daemonset calico-node -n kube-system -o yaml > calico-node.yaml
code calico-node.yaml


- Delete the entire initContainers: block for mount-bpffs
- Save and apply:
kubectl apply -f calico-node.yaml




2.Reapply Calico Manifest (to fix RBAC + CRDs)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml



3. Restart Calico Pods
kubectl delete pod -n kube-system -l k8s-app=calico-node
kubectl delete pod -n kube-system -l k8s-app=calico-kube-controllers



4. Verify Calico Recovery
kubectl get pods -n kube-system




Expected:
calico-node-xxxxx              1/1   Running
calico-kube-controllers-xxxxx  1/1   Running



5. Restart Ingress Controller
kubectl delete pod -n ingress -l app=nginx-ingress-microk8s
kubectl get pods -n ingress


Expected:
nginx-ingress-microk8s-controller-xxxxx   1/1   Running



6. Test Ingress Route
curl http://local.kubernetes.test/workerservice/api/WorkerService





