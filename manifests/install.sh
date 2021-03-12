#git clone https://github.com/chinaboy007/kube-prometheus
#cd kube-prometheus

online() {
   echo "开始在线安装，请确保node节点能连外网哦"
}

offline(){
echo "1.开始下载离线镜像"
md5key=`md5sum node.conf |awk '{print $1}'`
if [ "$md5key" == "d2d5f52990b40d361c49274076127cf1" ];then
    echo "[ERROR!],请先编辑离线安装配置文件node.conf,将node节点IP替换成自己的"
    exit 1
else
   for i in `cat node.conf`
   do 
      echo "发送kube-prometheus离线镜像包到node节点"
      scp -r add/images $i:/tmp/
      echo "----------------------------------"
      echo "开始在node节点安装kube-prometheus离线镜像"
      ssh $i "cd /tmp/images;sh image-load.sh"
   done
   ###传送node-exporter nfs-client-provisioner离线镜像包到master节点
fi
md5key=`md5sum master.conf |awk '{print $1}'`
if [ "$md5key" == "da905b64ee9b52c2add269a3e79a2e5e" ];then
    echo "[ERROR!],请先编辑离线安装配置文件master.conf,将master节点IP替换成自己的"
    exit 1
else
   for i in `cat master.conf`
   do
      echo "传送node-export镜像包到master节点"
      scp -r add/images $i:/tmp/
      echo "----------------------------------"
      echo "开始在node节点安装node-exporter nfs-client-provisioner离线镜像"
      ssh $i "cd /tmp/images/images-prometheus-optrator;docker load -i quay.io-external_storage-nfs-client-provisioner-latest.tgz;docker load -i quay.io-prometheus-node-exporter-v0.18.1.tgz"
   done
fi
}

echo "------------------------"
echo "1.在线安装(node节点访问外网下载镜像)"
echo "2.离线安装(node节点离线加载镜像，推荐)"
echo "------------------------"
read -p  "请选择安装方式：(1 or 2):" a
case $a in 
   1)
     online;;
   2)
     offline;;
   *)
     echo "[ERROR!]只能输入1或2"
     exit 1
esac


###开始安装kube-prometheus
echo ""
echo "2.start install kube-prometheus"
kubectl create -f setup >/dev/null 2>&1 
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl create -f ./ >/dev/null 2>&1

###配置kube-controller kube-scheduler kube-etcd等监控
echo
cd add/k8s-monitor
echo "3.config kube-controller kube-scheduler etcd servicemonitor"
sh k8s-monitor.sh
cd ..


###配置自动发现
echo
echo "4.开始配置自动发现"
cd autofind
sh install.sh
cd ..



###为grafana prometheus alert-manager服务配置NodePort
echo
echo "5.配置grafana prometheus alert-manager ui通过nodeport访问"
sh nodeport.sh
echo "---------------------------------------------------"
echo "install successful!check..."
echo "***************************************************"
echo "you can access dashboard for NodePort"
echo "grafana       NodePoert:30000"
echo "prometheus    NodePoert:30090"
echo "alert-manager NodePoert:30093"
echo ""


###grafana prometheus alert-manager服务配置nginx-ingress
echo "6.配置grafana prometheus alert-manager ui通过nginx-ingress访问"
kubectl get pod |grep ingress >/dev/null 2>&1
if [ $? -eq 0 ];then
   namespace=default
else
   namespace=nginx-ingress
fi
loadbalance_port=`kubectl get svc -n $namespace |grep LoadBalancer |awk '{print $5}'|awk -F'/' '{print $1}' |awk -F':' '{print $2}'`
kubectl apply -f ingress/ingress-monitor.yaml
echo ""
echo "***************************************************"
echo "you can access dashboard for nginx-ingress"
echo "grafana       http://grafana.k8s.com:$loadbalance_port"
echo "prometheus    http://prome.k8s.com:$loadbalance_port"
echo "alert-manager http://alert.k8s.com:$loadbalance_port"

echo
sleep 3
echo "deploy successful!"
echo "--------------------------------------------------"
kubectl get pod -n monitoring
