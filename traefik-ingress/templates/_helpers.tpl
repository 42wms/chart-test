{{/*
Expand the name of the chart.
*/}}
{{- define "traefik-ingress.name" -}}
{{- default .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "traefik-ingress.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "traefik-ingress.labels" -}}
helm.sh/chart: {{ include "traefik-ingress.chart" . }}
{{ include "traefik-ingress.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "traefik-ingress.selectorLabels" -}}
app.kubernetes.io/name: {{ include "traefik-ingress.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
cors middleware Default configuration
*/}}
{{- define "traefik-ingress.middleware.cors" -}}
accessControlAllowHeaders: [ "*" ]
accessControlAllowMethods:
  - "GET"
  - "POST"
  - "PUT"
  - "OPTIONS"
  - "PATCH"
  - "DELETE"
accessControlAllowOriginList: [ "*" ]
accessControlMaxAge: 100
addVaryHeader: true
{{- end }}

{{/*
forwardAuth middleware Default configuration
*/}}
{{- define "traefik-ingress.middleware.forwardAuth" -}}
trustForwardHeader: true
{{- end }}

{{/*
basicAuth middleware Default configuration
*/}}
{{- define "traefik-ingress.middleware.basicAuth" -}}
removeHeader: true
{{- end }}

{{/*
tlsRedirect middleware Default configuration
*/}}
{{- define "traefik-ingress.middleware.tlsRedirect" -}}
scheme: https
permanent: true
{{- end }}
