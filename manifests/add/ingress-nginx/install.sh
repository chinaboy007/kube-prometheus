#!/bin/bash

prometheus_clusterip=`kc get svc -n monitoring |grep k8s |awk '{print $3}'`

kubectl apply -f prometheus-ingress-nginx-service.yaml
kubectl apply -f prometheus-ingress-nginx-ep.yaml
kubectl apply -f prometheus-ingress-nginx-serviceMonitor.yaml
kubectl apply -f prometheus-ingress-nginxRules.yaml
curl -XPOST http://${prometheus_clusterip}:9090/-/reload 
