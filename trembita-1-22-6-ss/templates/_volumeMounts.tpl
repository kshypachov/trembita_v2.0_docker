{{- define "trembita.volumeMountsAndCM" -}}
{{- $start_context := .ctx }}
{{- $root := .root }}

{{/*  {{- if or ( or (and $root.Values.trembita_config.configMaps.enabled $start_context.configMaps) (and $start_context.sharedVolumes $root.Values.trembita_config.sharedVolumes)) .ephemeralVolumeRAM }}*/}}
{{- $hasCM := and $root.Values.trembita_config.configMaps.enabled $start_context.configMaps }}
{{- $hasSV := and $start_context.sharedVolumes $root.Values.trembita_config.sharedVolumes }}
{{- $hasST := and $start_context.secrets $root.Values.trembita_config.secrets}}
{{- if or $hasCM $hasSV $start_context.ephemeralVolumeRAM $hasST }}

          volumeMounts:
            {{- range $key, $cm := $root.Values.trembita_config.configMaps }}
              {{- if and (kindIs "map" $cm) ($root.Values.trembita_config.configMaps.enabled) }}
                {{- if and $cm.enabled (has $key $start_context.configMaps) }}
            - name: {{ $cm.name }}-cf-volume
              mountPath: {{ $cm.mountPath }}
              {{- if $cm.subPath }}
              subPath: {{ $cm.subPath }}
              readOnly: true
              {{- end }}
                {{- end }}
              {{- end }}
            {{- end }}
            {{- range $name, $cfg := $root.Values.trembita_config.sharedVolumes }}
              {{- if and $cfg.enabled (has $name $start_context.sharedVolumes) }}
            - name: {{ $name }}-volume
              mountPath: {{ $cfg.mountPath }}
              {{- end }}
            {{- end }}
            {{- range  $start_context.ephemeralVolumeRAM}}
            - name: {{ .name }}-ram-vol
              mountPath: {{ .mountPath }}
              {{- end}}
            {{- range $name, $cfg := $root.Values.trembita_config.secrets }}
             {{- if and $cfg.enabled (has $name $start_context.secrets) }}
             - name: {{ $name }}-secret-volume
               mountPath: {{ $cfg.mountPath }}
               readOnly: true
             {{- end }}
            {{- end }}

      volumes:
         {{- range $key, $cm := $root.Values.trembita_config.configMaps }}
           {{- if and (kindIs "map" $cm) ($root.Values.trembita_config.configMaps.enabled) }}
             {{- if and $cm.enabled (has $key $start_context.configMaps) }}
         - name: {{ $cm.name }}-cf-volume
           configMap:
             name: {{ $cm.name }}
               {{- end }}
             {{- end }}
           {{- end }}
           {{- range $name, $cfg := $root.Values.trembita_config.sharedVolumes }}
             {{- if and $cfg.enabled (has $name $start_context.sharedVolumes) }}
         - name: {{ $name }}-volume
           persistentVolumeClaim:
             claimName: {{ printf "%s-%s" (include "trembita-1-22-6-ss.fullname" $root) $name }}
             {{- end }}
           {{- end }}
           {{- range $start_context.ephemeralVolumeRAM}}
         - name: {{.name}}-ram-vol
           emptyDir:
             medium: Memory
             sizeLimit: {{ .sizeLimit }}
           {{- end }}
     {{- end }}
{{- end }}