#!/bin/bash

prometheus_clusterip=`kubectl get svc -n monitoring |grep k8s |awk '{print $3}'`

kubectl apply -f service.yaml
kubectl apply -f endpoint.yaml
kubectl apply -f servicemonitor.yaml
kubectl apply -f rules.yaml
curl -XPOST http://${prometheus_clusterip}:9090/-/reload 
