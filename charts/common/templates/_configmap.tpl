{{- define "common.configmap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}-config
  labels:
    {{- include "common.labels" . | nindent 4 }}
data:
  {{- range $k, $v := .Values.config }}
  {{- if $v }}
  {{ $k }}: {{ $v | quote }}
  {{- end }}
  {{- end }}
{{- end }}
