{{- define "common.secret" -}}
{{- if not .Values.secrets.existingSecret -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
type: Opaque
stringData:
  {{- with .Values.secrets.DISCORD_TOKEN }}
  DISCORD_TOKEN: {{ . | quote }}
  {{- end }}
  {{- with .Values.secrets.WEBHOOK_AUTHORIZATION_TOKEN }}
  WEBHOOK_AUTHORIZATION_TOKEN: {{ . | quote }}
  {{- end }}
  {{- with .Values.secrets.TOP_GG_TOKEN }}
  TOP_GG_TOKEN: {{ . | quote }}
  {{- end }}
  {{- with .Values.secrets.DISCORDBOTLIST_TOKEN }}
  DISCORDBOTLIST_TOKEN: {{ . | quote }}
  {{- end }}
  {{- with .Values.secrets.LOKI_PASSWORD }}
  LOKI_PASSWORD: {{ . | quote }}
  {{- end }}
  {{- with .Values.secrets.SENTRY_DSN }}
  SENTRY_DSN: {{ . | quote }}
  {{- end }}
  {{- with .Values.secrets.WIKTIONARY_USERNAME }}
  WIKTIONARY_USERNAME: {{ . | quote }}
  {{- end }}
  {{- with .Values.secrets.WIKTIONARY_PASSWORD }}
  WIKTIONARY_PASSWORD: {{ . | quote }}
  {{- end }}
  {{- $dbUrl := include "common.databaseUrl" . }}
  {{- if $dbUrl }}
  DATABASE_URL: {{ $dbUrl | quote }}
  {{- end }}
  {{- $valkeyUrl := include "common.valkeyUrl" . }}
  {{- if $valkeyUrl }}
  VALKEY_URL: {{ $valkeyUrl | quote }}
  {{- end }}
{{- end }}
{{- end }}
