{{/*
Expand the name of the chart.
*/}}
{{- define "postgres-ha.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgres-ha.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgres-ha.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "postgres-ha.labels" -}}
helm.sh/chart: {{ include "postgres-ha.chart" . }}
{{ include "postgres-ha.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "postgres-ha.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgres-ha.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
cluster-name: {{ include "postgres-ha.fullname" . }}
{{- end }}

{{/*
Match labels for selectors
*/}}
{{- define "postgres-ha.matchLabels" -}}
{{ include "postgres-ha.selectorLabels" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "postgres-ha.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "postgres-ha.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "postgres-ha.primaryServiceName" -}}
{{ printf "%s-primary" (include "postgres-ha.fullname" .) }}
{{- end }}

{{- define "postgres-ha.replicaServiceName" -}}
{{ printf "%s-replica" (include "postgres-ha.fullname" .) }}
{{- end }}

{{- define "postgres-ha.headlessServiceName" -}}
{{ printf "%s-hl" (include "postgres-ha.fullname" .) }}
{{- end }}
