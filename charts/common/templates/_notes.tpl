{{- define "common.notes" -}}
{{ .Chart.Name }} has been deployed!

  Release name: {{ .Release.Name }}
  Namespace:    {{ .Release.Namespace }}

Get the application URL:
{{- if .Values.ingress.enabled }}
{{- range $host := .Values.ingress.hosts }}
  http{{ if $.Values.ingress.tls }}s{{ end }}://{{ $host.host }}
{{- end }}
{{- else if contains "NodePort" .Values.service.type }}
  export NODE_PORT=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "common.fullname" . }})
  export NODE_IP=$(kubectl get nodes --namespace {{ .Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
  echo "http://$NODE_IP:$NODE_PORT"
{{- else if contains "LoadBalancer" .Values.service.type }}
  export SERVICE_IP=$(kubectl get svc --namespace {{ .Release.Namespace }} {{ include "common.fullname" . }} --template "{{"{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}"}}")
  echo "http://$SERVICE_IP:{{ .Values.service.port }}"
{{- else }}
  kubectl --namespace {{ .Release.Namespace }} port-forward svc/{{ include "common.fullname" . }} 8080:{{ .Values.service.port }}
  echo "http://localhost:8080"
{{- end }}

Metrics: http://<host>/api/metrics
{{- end }}
