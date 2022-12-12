{{- define "metachart.preprocess.deployments" -}}
{{- /* Cleanup context from the function params */}}
{{- $params := $.params | deepCopy }}
{{- $context := omit $ "params" }}
{{- /* Get params */}}
{{- $definition := $params.definition }}
{{- $name := $params.name }}
{{- $component := $params.component }}
{{- /* Execution */}}
{{- /* Set spec.selector */}}
{{- $_ := set $definition.spec "selector" (dict "matchLabels" (include "metachart.selectorLabels" (merge (dict "params"
  (dict
    "component" $component
  )) $context) | fromJson) ) }}
{{- /* Read pod definition */}}
{{- $pod := $definition.spec.pod | deepCopy }}
{{- $_ = unset $definition.spec "pod" }}
{{- /* Apply metadata */}}
{{- $_ = set $pod "metadata" (include "metachart.resourceMeta" (merge (dict "params"
  (dict
    "definition" $pod
    "name" $name
    "component" $component
    "withName" false
  )) $context) | fromJson) }}
{{- /* Apply pod defaults */}}
{{- $pod = include "metachart.setDefaults" (merge (dict "params"
  (dict
    "definition" $pod
    "kind" "pods"
  )) $context) | fromJson }}
{{- /* Set spec.template */}}
{{- $_ = set $definition.spec "template" (include "metachart.preprocess.pods" (merge (dict "params"
  (dict
    "definition" $pod
    "name" $name
    "component" $component
  )) $context) | fromJson)
}}
{{- /* Return */}}
{{- $definition | toJson }}
{{- end }}
