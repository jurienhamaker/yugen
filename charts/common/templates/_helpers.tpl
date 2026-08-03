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
common.dbExistingSecret: name of the k8s Secret that holds the Postgres password,
or empty when none is configured.

Guard: when secrets.existingSecret is set the user owns the entire bot Secret
(including DATABASE_URL) — return empty so no runtime env injection fires.

Priority mirrors common.databaseUrl:
  global.sharedInfra  → global.postgresql.auth.existingSecret
  postgresql.enabled  → postgresql.auth.existingSecret
*/}}
{{- define "common.dbExistingSecret" -}}
{{- if .Values.secrets.existingSecret -}}
{{- /* guard: user owns the full bot secret */ -}}
{{- else if (.Values.global).sharedInfra -}}
{{- ((((.Values.global).postgresql).auth).existingSecret) -}}
{{- else if (.Values.postgresql).enabled -}}
{{- (((.Values.postgresql).auth).existingSecret) -}}
{{- end -}}
{{- end }}

{{/*
common.dbPasswordKey: the key inside the DB existingSecret that holds the password.
Defaults to "password" — Bitnami's userPasswordKey default.
*/}}
{{- define "common.dbPasswordKey" -}}
{{- if (.Values.global).sharedInfra -}}
{{- default "password" ((((.Values.global).postgresql).auth).secretKeys).userPasswordKey -}}
{{- else -}}
{{- default "password" (((.Values.postgresql).auth).secretKeys).userPasswordKey -}}
{{- end -}}
{{- end }}

{{/*
common.databaseUrlTemplate: like common.databaseUrl but with the literal
$(DB_PASSWORD) placeholder instead of the actual password value.
Only meaningful for tiers 1 & 2 (subchart-backed postgres).
*/}}
{{- define "common.databaseUrlTemplate" -}}
{{- if (.Values.global).sharedInfra -}}
{{- printf "postgres://%s:$(DB_PASSWORD)@%s-postgresql:5432/%s?sslmode=disable" .Values.global.postgresql.auth.username .Release.Name .Chart.Name -}}
{{- else if (.Values.postgresql).enabled -}}
{{- printf "postgres://%s:$(DB_PASSWORD)@%s-postgresql:5432/%s?sslmode=disable" .Values.postgresql.auth.username (include "common.fullname" .) .Values.postgresql.auth.database -}}
{{- end -}}
{{- end }}

{{/*
common.dbEnv: renders the DB_PASSWORD secretKeyRef + DATABASE_URL $(VAR)-expansion
env entries when a Postgres existingSecret is configured.
Output is a YAML list fragment — nindent it into an env: block.
Renders nothing when no existingSecret is in play.
*/}}
{{- define "common.dbEnv" -}}
{{- $secret := include "common.dbExistingSecret" . }}
{{- if $secret }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $secret }}
      key: {{ include "common.dbPasswordKey" . }}
- name: DATABASE_URL
  value: {{ include "common.databaseUrlTemplate" . | quote }}
{{- end -}}
{{- end }}

{{/*
DATABASE_URL for bots backed by PostgreSQL.
Priority: global.sharedInfra (umbrella) → postgresql.enabled (standalone) → secrets.DATABASE_URL (external).
In sharedInfra mode the DB name is .Chart.Name (bot name == database name by convention).
When a Postgres existingSecret is active (tiers 1 & 2) this returns empty so the
chart-managed Secret omits DATABASE_URL — it is composed at runtime via common.dbEnv.
*/}}
{{- define "common.databaseUrl" -}}
{{- if (.Values.global).sharedInfra -}}
{{- if not (include "common.dbExistingSecret" .) -}}
{{- printf "postgres://%s:%s@%s-postgresql:5432/%s?sslmode=disable" .Values.global.postgresql.auth.username .Values.global.postgresql.auth.password .Release.Name .Chart.Name -}}
{{- end -}}
{{- else if (.Values.postgresql).enabled -}}
{{- if not (include "common.dbExistingSecret" .) -}}
{{- printf "postgres://%s:%s@%s-postgresql:5432/%s?sslmode=disable" .Values.postgresql.auth.username .Values.postgresql.auth.password (include "common.fullname" .) .Values.postgresql.auth.database -}}
{{- end -}}
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
