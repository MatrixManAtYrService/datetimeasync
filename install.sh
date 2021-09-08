set -x pipefail

# delete all previous namespaces prefixed with iter-
cat <<- 'EOF' | bash &
kubectl get namespaces | egrep '^iter-' | awk '{print $1}' | xargs kubectl delete namespace
EOF

NS="$(date +%s | sed 's/.*\(.....\)/\1/')"

# build the image and push it
docker pull quay.io/astronomer/ap-airflow-dev:2.2.0-buster
docker build . -t temp:$NS
docker tag temp:$NS 192.168.90.13:30500/temp:$NS
docker push 192.168.90.13:30500/temp:$NS

# make a new namespace prefixed iter
kubectl create namespace iter-$NS

# helm install
cat <<- 'EOF' | sed "s/\$TAG/$NS/" \
              | tee /dev/fd/2 \
              | helm install airflow /Users/matt/src/astronomer-airflow/chart \
                     --namespace iter-$NS \
                     -f -
airflowHome: /usr/local/airflow
airflowVersion: 2.2.0
defaultAirflowRepository: 192.168.90.13:30500/temp
defaultAirflowTag: "$TAG"
env:
- name: AIRFLOW__SCHEDULER__SCHEDULER_HEARTBEAT_SEC
  value: '2'
executor: KubernetesExecutor
gid: 50000
images:
  airflow:
    pullPolicy: Always
  flower:
    pullPolicy: Always
  pod_template:
    pullPolicy: Always
logs:
  persistence:
    enabled: true
    size: 1Gi
webserver:
  args:
  - airflow
  - webserver
scheduler:
  logGroomerSidecar:
    args: ["/usr/local/bin/clean-airflow-logs"]
EOF

kubectl port-forward svc/airflow-webserver 8080:8080 --namespace iter-$NS
set +x
