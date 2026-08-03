{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "common.labels" -}}
helm.sh/chart: {{ include "common.chart" . }}
{{ include "common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Secret name: existingSecret when supplied, else the chart-managed secret.
*/}}
{{- define "common.secretName" -}}
{{- if .Values.secrets.existingSecret -}}
{{- .Values.secrets.existingSecret -}}
{{- else -}}
{{- include "common.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
DATABASE_URL for bots backed by PostgreSQL.
Priority: global.sharedInfra (umbrella) → postgresql.enabled (standalone) → secrets.DATABASE_URL (external).
In sharedInfra mode the DB name is .Chart.Name (bot name == database name by convention).
*/}}
{{- define "common.databaseUrl" -}}
{{- if (.Values.global).sharedInfra -}}
{{- printf "postgres://%s:%s@%s-postgresql:5432/%s?sslmode=disable" .Values.global.postgresql.auth.username .Values.global.postgresql.auth.password .Release.Name .Chart.Name -}}
{{- else if (.Values.postgresql).enabled -}}
{{- printf "postgres://%s:%s@%s-postgresql:5432/%s?sslmode=disable" .Values.postgresql.auth.username .Values.postgresql.auth.password (include "common.fullname" .) .Values.postgresql.auth.database -}}
{{- else -}}
{{- .Values.secrets.DATABASE_URL -}}
{{- end -}}
{{- end }}

{{/*
VALKEY_URL for bots backed by Valkey (kusari).
Priority: global.sharedInfra → valkey.enabled (standalone) → secrets.VALKEY_URL (external).
*/}}
{{- define "common.valkeyUrl" -}}
{{- if (.Values.global).sharedInfra -}}
{{- printf "valkey://%s-valkey-master:6379/0" .Release.Name -}}
{{- else if (.Values.valkey).enabled -}}
{{- if ((.Values.valkey).auth).enabled -}}
{{- printf "valkey://:%s@%s-valkey-master:6379/0" .Values.valkey.auth.password (include "common.fullname" .) -}}
{{- else -}}
{{- printf "valkey://%s-valkey-master:6379/0" (include "common.fullname" .) -}}
{{- end -}}
{{- else -}}
{{- .Values.secrets.VALKEY_URL -}}
{{- end -}}
{{- end }}
