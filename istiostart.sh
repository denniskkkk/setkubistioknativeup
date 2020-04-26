istioctl manifest apply --set profile=default  \
  --set values.gateways.enabled=true \
  --set values.gateways.istio-ingressgateway.enabled=true \
  --set values.grafana.enabled=true \
  --set values.kiali.enabled=true \
  --set values.prometheus.enabled=true \
  --set values.tracing.enabled=true \
  --set values.tracing.provider=zipkin \
  --set values.sidecarInjectorWebhook.enabled=true \
  --set values.sidecarInjectorWebhook.enableNamespacesByDefault=true \
  --set values.global.proxy.autoInject=disabled \
  --set values.global.disablePolicyChecks=true \
  `#--set values.prometheus.enabled=true ` \
  `# Disable mixer prometheus adapter to remove istio default metrics.` \
  --set values.mixer.adapters.prometheus.enabled=true \
  `# Disable mixer policy check, since in our template we set no policy.` \
  --set values.global.disablePolicyChecks=true \
  --set values.gateways.istio-ingressgateway.autoscaleMin=1 \
  --set values.gateways.istio-ingressgateway.autoscaleMax=2 \
  --set values.gateways.istio-ingressgateway.resources.requests.cpu=500m \
  --set values.gateways.istio-ingressgateway.resources.requests.memory=256Mi \
  `# Enable SDS in the gateway to allow dynamically configuring TLS of gateway.` \
  --set values.gateways.istio-ingressgateway.sds.enabled=true \
  `# More pilot replicas for better scale` \
  --set values.pilot.autoscaleMin=2 \
  `# Set pilot trace sampling to 100%` \
  --set values.pilot.traceSampling=100 
istioctl manifest apply --set values.kiali.enabled=true


kubectl label --overwrite namespace default istio-injection=enabled
kubectl patch svc istio-ingressgateway -nistio-system --patch '{"spec": { "externalIPs": ["192.168.1.25"] }}'
#kubectl patch svc istio-ingressgateway --namespace istio-system --patch '{"spec": { "loadBalancerIP": "<your-reserved-static-ip>" }}'

# prometheus
kubectl patch svc -n istio-system prometheus --patch '{ "spec" : {  "type"  :  "NodePort"  } }'
kubectl patch svc -n istio-system prometheus --patch '{ "spec" : {  "ports"  : [ { "name": "http-prometheus" , "port" : 9090,  "nodePort" : 32090 , "protocol" : "TCP", "targetPort" : 9090 } ] } }'


#zipkin
kubectl patch svc -n istio-system zipkin --patch '{ "spec" : {  "type"  :  "NodePort"  } }'
kubectl patch svc -n istio-system zipkin --patch '{ "spec" : {  "ports"  : [ { "name": "http" , "port" : 9411 ,  "nodePort" : 32411 , "protocol" : "TCP", "targetPort" : 9411 } ] } }'

