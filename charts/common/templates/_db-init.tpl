{{/*
common.dbInitContainers: renders the init-container list fragment for DB-backed bots.

Produces two init containers when migrations are enabled:
  1. wait-db  — busybox nc loop; waits for the Postgres Service to accept TCP
                connections before proceeding. Skipped for external-DB bots
                (where common.dbHost is empty).
  2. migrate  — bot image; runs "atlas migrate apply --env production".
                Idempotent and protected by an advisory lock, so safe across
                replica rollouts.

Usage in _deployment.tpl:
  {{- $init := include "common.dbInitContainers" . | trim }}
  {{- if $init }}
  initContainers:
    {{- $init | nindent 8 }}
  {{- end }}
*/}}
{{- define "common.dbInitContainers" -}}
{{- if .Values.migrations }}
{{- if .Values.migrations.enabled }}
{{- $dbHost := include "common.dbHost" . | trim }}
{{- $dbEnv := include "common.dbEnv" . | trim }}
{{- if $dbHost }}
- name: wait-db
  image: {{ default "busybox:1.36" .Values.initImage | quote }}
  imagePullPolicy: IfNotPresent
  command:
    - /bin/sh
    - -c
    - until nc -z {{ $dbHost }} 5432; do echo "waiting for postgres at {{ $dbHost }}:5432"; sleep 2; done
{{- end }}
- name: migrate
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  workingDir: /opt/app
  command:
    - /bin/sh
    - -c
    - atlas migrate apply --env production --url {{ $dbEnv }}
  envFrom:
    - secretRef:
        name: {{ include "common.secretName" . }}
{{- if $dbEnv }}
  env:
    {{- $dbEnv | nindent 4 }}
{{- end }}
{{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
