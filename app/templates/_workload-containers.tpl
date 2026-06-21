{{- define "container.restartPolicy" -}}
{{- $ := index . 0}}
{{- $containerType := index . 2 }}
{{- with index . 1 -}}
{{- if eq $containerType "initContainer" -}}
restartPolicy: {{ .containerRestartPolicy | default "Always" }}
{{- else }}
{{- with .containerRestartPolicy -}}
restartPolicy: {{ . }}
{{- end }}
{{- end }}
{{ end }}
{{- end }}

{{- define "container.securityContext" -}}
{{- with .securityContext -}}
securityContext:
  {{- toYaml . | nindent 2 }}
{{ end }}
{{- end }}

{{- define "container.image" -}}
image: "{{ .image.repository }}:{{ .image.tag }}"
{{ end }}

{{- define "container.imagePullPolicy" -}}
imagePullPolicy: {{ .image.pullPolicy }}
{{ end }}

{{- define "container.command" -}}
command: {{ toJson .command }}
{{ end }}

{{- define "container.args" -}}
args: {{ toJson .args }}
{{ end }}

{{- define "container.envFrom.values" -}}
{{- with .envFrom -}}
{{- toYaml . }}
{{ end }}
{{- end }}

{{- define "container.envFrom" -}}
{{- $ := index . 0}}
{{- $containerType := index . 2 }}
{{- with index . 1 -}}
{{- $useSecret := and .envSecret (eq $containerType "appContainer") }}
{{- if or .envFrom $useSecret -}}
envFrom:
  {{- if $useSecret }}
  - secretRef:
      name: {{ template "app.envSecretName" $ }}
  {{- end }}
  {{- include "container.envFrom.values" . | nindent 2 }}
{{- end }}
{{ end }}
{{- end }}

{{- define "container.env" -}}
{{- with .env -}}
env:
  {{- range $name, $value := . }}
  {{- $_ := required (printf "%s value required" $name) $value }}
  {{- if kindIs "map" $value }}
  - name: {{ $name | quote }}
    valueFrom:
      {{- toYaml $value | nindent 6 }}
  {{- end }}
  {{- end }}
  {{- range $name, $value := . }}
  {{- $_ := required (printf "%s value required" $name) $value }}
  {{- if not (kindIs "map" $value) }}
  - name: {{ $name | quote }}
    value: {{ $value | quote }}
  {{- end }}
  {{- end }}
{{ end }}
{{- end }}

{{- define "container.ports" -}}
{{- with .ports -}}
ports:
{{- range . }}
  - name: {{ .name }}
    containerPort: {{ .containerPort }}
    protocol: {{ .protocol }}
{{- end }}
{{ end }}
{{- end }}

{{- define "container.resizePolicy" -}}
{{- with .resizePolicy -}}
resizePolicy:
  {{- toYaml . | nindent 2 }}
{{ end }}
{{- end }}

{{- define "container.restartPolicyRules" -}}
{{- with .restartPolicyRules -}}
restartPolicyRules:
  {{- toYaml . | nindent 2 }}
{{ end }}
{{- end }}

{{- define "container.lifecycle" -}}
{{- with .lifecycle -}}
lifecycle:
  {{- toYaml . | nindent 2 }}
{{ end }}
{{- end }}

{{- define "container.livenessProbe" -}}
{{- with .livenessProbe -}}
livenessProbe:
  {{- toYaml . | nindent 2 }}
{{ end }}
{{- end }}

{{- define "container.readinessProbe" -}}
{{- with .readinessProbe -}}
readinessProbe:
  {{- toYaml . | nindent 2 }}
{{ end }}
{{- end }}

{{- define "container.startupProbe" -}}
{{- with .startupProbe -}}
startupProbe:
  {{- toYaml . | nindent 2 }}
{{ end }}
{{- end }}

{{- define "container.resources" -}}
{{- with .resources -}}
resources:
  {{- toYaml . | nindent 2 }}
{{ end }}
{{- end }}

{{- define "container.volumeMounts" -}}
{{- with .volumeMounts -}}
volumeMounts:
  {{- toYaml . | nindent 2 }}
{{ end }}
{{- end }}

{{- define "container.workingDir" -}}
{{- with .workingDir -}}
workingDir: {{ . }}
{{ end }}
{{- end }}

{{/*
Renders the full container spec body (everything below the `name:` field),
shared by both initContainers and the main containers list.

Arguments: a two-element list passed via `include`:
  - index 0: $ context
  - index 1: the container's values map (its config from values.yaml)
  - index 2: containerType — either "appContainer" or "initContainer".
             Used to branch on spec rules that differ between the two types
             (e.g. the auto-injected env secret is only added for appContainer).

Usage:
  {{- $containerType := "initContainer" }}
  - name: "initApp"
    {{- include "container.spec" (list $ .Values $containerType) | nindent 2 }}

NOTE: the caller is responsible for emitting the `- name:` line; this template
only renders the fields that follow it.
*/}}
{{- define "container.spec" -}}
{{- $ := index . 0}}
{{- $containerType := index . 2 }}
{{- with index . 1 -}}
{{- include "container.restartPolicy" (list $ . $containerType) }}
{{- include "container.securityContext" . }}
{{- include "container.image" . }}
{{- include "container.imagePullPolicy" . }}
{{- include "container.command" . }}
{{- include "container.args" . }}
{{- include "container.envFrom" (list $ . $containerType) }}
{{- include "container.env" . }}
{{- include "container.ports" . }}
{{- include "container.resizePolicy" . }}
{{- include "container.restartPolicyRules" . }}
{{- include "container.lifecycle" . }}
{{- include "container.livenessProbe" . }}
{{- include "container.readinessProbe" . }}
{{- include "container.startupProbe" . }}
{{- include "container.resources" . }}
{{- include "container.volumeMounts" . }}
{{- include "container.workingDir" . }}
{{- end }}
{{- end }}

{{/*
Builds the ordered list of init containers for the pod spec.

`.Values.initContainers` is authored as a map (name -> container config),
which Helm/Go templates iterate in alphabetical order — not the order the
init containers must actually run in. This template restores explicit
ordering using each container's `.order` field.
*/}}
{{- define "initContainers.sorted" -}}
{{- $indexed := dict -}}
{{- $containerType := "initContainer" -}}
{{- range $name, $container := $.Values.initContainers -}}
  {{- $key := printf "%03d_%s" ($container.order | int) $name -}}
  {{- $_ := set $indexed $key $name -}}
{{- end -}}
{{- range $key := (keys $indexed | sortAlpha) -}}
{{- $name := index $indexed $key -}}
{{- $container := index $.Values.initContainers $name }}
- name: {{ $name }}
  {{- include "container.spec" (list $ $container $containerType) | nindent 2 }}
{{- end }}
{{- end }}
