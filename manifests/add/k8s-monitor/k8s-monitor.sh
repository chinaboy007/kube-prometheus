kubectl apply -f controller/prometheus-kubeControllermanagerService.yaml
kubectl apply -f scheduler/prometheus-kubeSchedulerService.yaml
sed -i 's#bind-address=127.0.0.1#bind-address=0.0.0.0#g' /etc/kubernetes/manifests/kube-scheduler.yaml 
sed -i 's#bind-address=127.0.0.1#bind-address=0.0.0.0#g' /etc/kubernetes/manifests/kube-controller-manager.yaml 
#echo "kube-scheduler.yaml"
#cat /etc/kubernetes/manifests/kube-scheduler.yaml |grep bind-address
#echo "kube-controller-manager.yaml"
#cat /etc/kubernetes/manifests/kube-controller-manager.yaml |grep bind-address

echo "kube-etcd"
cd etcd
sh install.sh
cd ..
