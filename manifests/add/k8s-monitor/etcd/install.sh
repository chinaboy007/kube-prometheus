#!/bin/bash
cp prometheus-etcdService_tmpl.yaml  prometheus-etcdService.yaml
read -p "please input etcd_master1_ip:" etcd_master1_ip
read -p "please input etcd_master2_ip:" etcd_master2_ip
read -p "please input etcd_master3_ip:" etcd_master3_ip
sed -i "s/10.32.3.57/${etcd_master1_ip}/g" prometheus-etcdService.yaml
sed -i "s/10.32.3.58/${etcd_master2_ip}/g" prometheus-etcdService.yaml
sed -i "s/10.32.3.59/${etcd_master3_ip}/g" prometheus-etcdService.yaml
kubectl delete secret etcd-certs -n monitoring >/dev/null 2>&1
kubectl -n monitoring create secret generic etcd-certs --from-file=/etc/kubernetes/pki/etcd/healthcheck-client.crt --from-file=/etc/kubernetes/pki/etcd/healthcheck-client.key --from-file=/etc/kubernetes/pki/etcd/ca.crt
kubectl delete pod prometheus-k8s-0 -n monitoring >/dev/null 2>&1
kubectl delete pod prometheus-k8s-1 -n monitoring >/dev/null 2>&1
kubectl apply -f ../nfs-client/prometheus-prometheus.yaml
kubectl apply -f prometheus-serviceMonitorEtcd.yaml
kubectl apply -f prometheus-etcdService.yaml
kubectl apply -f prometheus-etcdRules.yaml
