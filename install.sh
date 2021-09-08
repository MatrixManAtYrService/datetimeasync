set -x pipefail

# delete all previous namespaces prefixed with iter-
cat <<- 'EOF' | bash &
kubectl get namespaces | egrep '^iter-' | awk '{print $1}' | xargs kubectl delete namespace
EOF

# build the image and push it
docker pull quay.io/astronomer/ap-airflow-dev:2.2.0-buster
docker build . -t temp:latest
docker tag temp:latest 192.168.90.13:30500/temp:latest
docker push 192.168.90.13:30500/temp:latest

# make a new namespace prefixed iter
NS="iter-$(date +%s)"
kubectl create namespace $NS

# helm install
helm repo add astronomer https://helm.astronomer.io
helm repo update
cat <<- 'EOF' | helm install airflow /Users/matt/src/airflow-chart \
                                --namespace $NS \
                                -f -
defaultAirflowRepository: 192.168.90.13:30500/temp
defaultAirflowTag: latest
executor: KubernetesExecutor
airflowVersion: 2.2.0
triggerer:
  serviceAccount:
    create: True
EOF

kubectl port-forward svc/airflow-webserver 8080:8080 --namespace $NS
set +x
