{{/*
Shared volumes list.
*/}}
{{- define "sharedVolumes.spec" -}}
{{- range $name, $volume := .Values.sharedVolumes -}}
- name: {{ $name }}
  {{- toYaml $volume | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Create sorted initContainers list.
*/}}
{{- define "initContainers.sorted" -}}
{{- $indexed := dict -}}
{{- range $name, $container := $.Values.initContainers -}}
  {{- $key := printf "%03d_%s" ($container.order | int) $name -}}
  {{- $_ := set $indexed $key $name -}}
{{- end -}}
{{- range $key := (keys $indexed | sortAlpha) -}}
{{- $name := index $indexed $key -}}
{{- $container := index $.Values.initContainers $name -}}
- name: {{ $name }}
  restartPolicy: {{ $container.restartPolicy | default "OnFailure" }}
  {{- with $container.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  image: "{{ $container.image.repository }}:{{ $container.image.tag }}"
  imagePullPolicy: {{ $container.image.pullPolicy }}
  command: {{ toJson $container.command }}
  args: {{ toJson $container.args }}
  {{- if $container.envFrom }}
  envFrom:
    {{- with $container.envFrom }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $container.env }}
  env:
  {{- range $name, $value := . }}
    {{- $_ := required (printf "%s value required" $name) $value }}
    {{- if kindIs "map" $value }}
    - name: {{ $name | quote }}
      valueFrom:
        {{- toYaml $value | nindent 8 }}
    {{- end }}
  {{- end }}
  {{- range $name, $value := . }}
    {{- $_ := required (printf "%s value required" $name) $value }}
    {{- if not (kindIs "map" $value) }}
    - name: {{ $name | quote }}
      value: {{ $value | quote }}
    {{- end }}
  {{- end }}
  {{- end }}
  {{- with $container.ports }}
  ports:
  {{- range . }}
    - name: {{ .name }}
      containerPort: {{ .containerPort }}
      protocol: {{ .protocol }}
  {{- end }}
  {{- end }}
  {{- with $container.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.livenessProbe }}
  livenessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.readinessProbe }}
  readinessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $container.volumeMounts }}
  volumeMounts:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{ end -}}
{{- end }}
