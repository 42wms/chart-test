{{/*
Renders the pod's `volumes:` list entries by aggregating several volume
sources, each independently toggled via its own `.enable` flag in values.yaml.
*/}}
{{- define "volumes.spec" -}}
{{- if .Values.volumesConfigMap.enable }}
{{- with .Values.volumesConfigMap.volumes }}
{{- range . }}
- name: {{ .name }}
  configMap:
    name: {{ template "app.name" $ }}-file-{{ .name }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.volumesExistingConfigMap.enable }}
{{- with .Values.volumesExistingConfigMap.volumes }}
{{- range . }}
- name: {{ .name }}
  configMap:
    name: {{ .name }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.volumesExistingSecret.enable }}
{{- with .Values.volumesExistingSecret.volumes }}
{{- range . }}
- name: {{ .name }}
  secret:
    secretName: {{ .name }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.volumesSecret.enable }}
{{- with .Values.volumesSecret.volumes }}
{{- range . }}
- name: {{ .name }}
  secret:
    secretName: {{ template "app.name" $ }}-file-{{ .name }}-secret
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.volumesHostPathMap.enable }}
{{- with .Values.volumesHostPathMap.volumes }}
{{- range . }}
- name: {{ .name }}
  hostPath:
    path: {{ .path }}
    type: {{ .type }}
{{- end }}
{{- end }}
{{- end }}
{{- with .Values.sharedVolumes }}
{{- range $name, $volume := . }}
- name: {{ $name }}
  {{- toYaml $volume | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
