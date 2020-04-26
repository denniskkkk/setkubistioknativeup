#disable istio sidecar insertion
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: istio-system
  overwrite: true
  labels:
    istio-injection: enabled
EOF



#if update from 0.3.x
#kubectl delete svc knative-ingressgateway -n istio-system
#kubectl delete deploy knative-ingressgateway -n istio-system

# If you have the Knative Eventing Sources component installed, you will also need to delete the following resource before upgrading
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/serving-crds.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/serving-core.yaml

kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/serving-istio.yaml
kubectl --namespace istio-system get service istio-ingressgateway


kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/serving-hpa.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/serving-cert-manager.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/serving-nscert.yaml

kubectl apply --filename https://github.com/knative/eventing/releases/download/v0.13.0/eventing-crds.yaml
kubectl apply --filename https://github.com/knative/eventing/releases/download/v0.13.0/eventing-core.yaml
kubectl apply --filename https://github.com/knative/eventing/releases/download/v0.13.0/in-memory-channel.yaml
kubectl apply --filename https://github.com/knative/eventing/releases/download/v0.13.0/channel-broker.yaml
kubectl get pods --namespace knative-eventing

kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/monitoring-core.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/monitoring-metrics-prometheus.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/monitoring-logs-elasticsearch.yaml

kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/monitoring-tracing-jaeger-in-mem.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/monitoring-tracing-zipkin-in-mem.yaml



kubectl get pods --namespace knative-serving
kubectl get pods --namespace knative-eventing
kubectl get pods --namespace knative-monitoring

# setup grafana nodePort port number
kubectl patch svc -n knative-monitoring grafana --patch '{ "spec" : {  "ports"  : [ { "port" : 30802 ,  "nodePort" : 31802 , "protocol" : "TCP", "targetPort" : 3000 } ] } }'


