{{/*
Expand the name of the chart.
*/}}
{{- define "flux-operator.name" -}}
{{- default (kebabcase .Chart.Name) .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "flux-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default (kebabcase .Chart.Name) .Values.nameOverride }}
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
{{- define "flux-operator.chart" -}}
{{- printf "%s-%s" (kebabcase .Chart.Name) .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "flux-operator.labels" -}}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | default "honeybadger" | quote }}
helm.sh/chart: {{ include "flux-operator.chart" . }}
{{ include "flux-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "resource.vpa.enabled" -}}
{{- if and (or (.Capabilities.APIVersions.Has "autoscaling.k8s.io/v1") (.Values.giantswarm.verticalPodAutoscaler.force)) (.Values.giantswarm.verticalPodAutoscaler.enabled) }}true{{ else }}false{{ end }}
{{- end -}}
