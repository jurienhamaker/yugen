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
common.dbPasswordSecretName: name of the k8s Secret that holds the Postgres password.

For Bitnami-backed Postgres (sharedInfra or postgresql.enabled) this defaults to the
auto-created secret (<release>-postgresql / <fullname>-postgresql) so no explicit
existingSecret is required. Falls back to a user-supplied existingSecret if set.

Priority:
  global.sharedInfra  → global.postgresql.auth.existingSecret || "<release>-postgresql"
  postgresql.enabled  → postgresql.auth.existingSecret        || "<fullname>-postgresql"
  external            → empty (DATABASE_URL comes from secrets.DATABASE_URL in the Secret)
*/}}
{{- define "common.dbPasswordSecretName" -}}
{{- if (.Values.global).sharedInfra -}}
{{- default (printf "%s-postgresql" .Release.Name) (dig "postgresql" "auth" "existingSecret" "" (.Values.global | default dict)) -}}
{{- else if (.Values.postgresql).enabled -}}
{{- default (printf "%s-postgresql" (include "common.fullname" .)) (dig "auth" "existingSecret" "" (.Values.postgresql | default dict)) -}}
{{- end -}}
{{- end }}

{{/*
common.dbPasswordKey: the key inside the DB password Secret that holds the password.
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
common.databaseUrlTemplate: DATABASE_URL with the literal $(DB_PASSWORD) placeholder.
Used by common.dbEnv so k8s expands the password from the secretKeyRef at runtime.
Only meaningful for Postgres-backed tiers (sharedInfra / postgresql.enabled).
*/}}
{{- define "common.databaseUrlTemplate" -}}
{{- if (.Values.global).sharedInfra -}}
{{- printf "postgres://%s:$(DB_PASSWORD)@%s-postgresql:5432/%s?sslmode=disable" .Values.global.postgresql.auth.username .Release.Name .Chart.Name -}}
{{- else if (.Values.postgresql).enabled -}}
{{- printf "postgres://%s:$(DB_PASSWORD)@%s-postgresql:5432/%s?sslmode=disable" .Values.postgresql.auth.username (include "common.fullname" .) .Values.postgresql.auth.database -}}
{{- end -}}
{{- end }}

{{/*
common.dbEnv: renders DB_PASSWORD (secretKeyRef) + DATABASE_URL ($(VAR) expansion)
env entries for every Postgres-backed bot — sharedInfra and standalone postgresql.enabled.
Output is a YAML list fragment; nindent it into an env: block.
Renders nothing for external-DB bots (DATABASE_URL comes from the chart-managed Secret).
*/}}
{{- define "common.dbEnv" -}}
{{- $secret := include "common.dbPasswordSecretName" . }}
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
common.dbHost: hostname of the Postgres Service (no port).
Used by the wait-db init container to gate on DB readiness.
Returns empty for external-DB bots (DATABASE_URL from secrets) — those skip
the wait loop and assume the DB is already reachable.
Priority mirrors common.databaseUrl.
*/}}
{{- define "common.dbHost" -}}
{{- if (.Values.global).sharedInfra -}}
{{- printf "%s-postgresql" .Release.Name -}}
{{- else if (.Values.postgresql).enabled -}}
{{- printf "%s-postgresql" (include "common.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
DATABASE_URL for bots backed by an **external** Postgres only (no subchart).
For sharedInfra and postgresql.enabled bots DATABASE_URL is composed at runtime
via common.dbEnv (DB_PASSWORD secretKeyRef + $(VAR) expansion) and must NOT be
baked into the chart-managed Secret — return empty for those tiers.
*/}}
{{- define "common.databaseUrl" -}}
{{- if (.Values.global).sharedInfra -}}
{{- /* runtime-composed via common.dbEnv */ -}}
{{- else if (.Values.postgresql).enabled -}}
{{- /* runtime-composed via common.dbEnv */ -}}
{{- else -}}
{{- .Values.secrets.DATABASE_URL -}}
{{- end -}}
{{- end }}

{{/*
VALKEY_URL for bots backed by Valkey (kusari).
Priority: global.sharedInfra (only when bot has valkey config) → valkey.enabled (standalone) → secrets.VALKEY_URL (external).
The .Values.valkey guard ensures non-valkey bots don't receive VALKEY_URL when sharedInfra is true.
*/}}
{{- define "common.valkeyUrl" -}}
{{- if and (.Values.global).sharedInfra .Values.valkey -}}
{{- printf "valkey://%s-valkey-master:6379/0" .Release.Name -}}
{{- else if (.Values.valkey).enabled -}}
{{- if ((.Values.valkey).auth).enabled -}}
{{- printf "valkey://:%s@%s-valkey-master:6379/0" .Values.valkey.auth.password (include "common.fullname" .) -}}
{{- else -}}
{{- printf "valkey://%s-valkey-master:6379/0" (include "common.fullname" .) -}}
{{- end -}}
{{- else -}}
{{- .Values.secrets.VALKEY_URL | default "" -}}
{{- end -}}
{{- end }}
