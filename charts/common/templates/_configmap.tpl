{{- define "common.configmap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}-config
  labels:
    {{- include "common.labels" . | nindent 4 }}
data:
  {{- $global := ((.Values.global).config) | default dict }}
  {{- $local := dict }}
  {{- range $k, $v := (.Values.config | default dict) }}
  {{- if $v }}{{- $_ := set $local $k $v }}{{- end }}
  {{- end }}
  {{- $cfg := mergeOverwrite (deepCopy $global) $local }}
  {{- range $k, $v := $cfg }}
  {{- if $v }}
  {{ $k }}: {{ $v | quote }}
  {{- end }}
  {{- end }}
{{- end }}
