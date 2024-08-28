{{/*
Call index function recursively. Check on each recursive call that the key exists. Instead of throwing an error if the key doesn't exist, do nothing.

The return type is always String. If another return type is required, use this function to test if the value exists and then access that value with the index function.
*/}}
{{- define "eric-oss-pf-apex.indexRecursive" -}}
    {{- $keys := (rest .) -}}
    {{- $dict := first . -}}
    {{- $innerValue := index $dict (first $keys) -}}
    {{ if not (kindIs "invalid" $innerValue) }}
        {{- $keysLeft := rest $keys -}}
        {{- if $keysLeft -}}
            {{- $args := prepend $keysLeft $innerValue -}}
            {{- include "eric-oss-pf-apex.indexRecursive" $args -}}
        {{- else -}}
            {{- $innerValue -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Given a list of .Values and any number of optional parameter names (including path), returns the first parameter that has a value.
Uses the indexRecursive function, so it is safe to use even if a parameter is not defined.
*/}}
{{- define "eric-oss-pf-apex.firstOptional" -}}
    {{- $values := first . -}}
     {{- $parameters := rest . -}}
     {{- if $parameters -}}
         {{- $currentParameter := first $parameters -}}
         {{- $indexRecursiveArgs := prepend (splitList "." $currentParameter) $values -}}
         {{- $currentValue := include "eric-oss-pf-apex.indexRecursive" $indexRecursiveArgs -}}
         {{- if $currentValue -}}
             {{- $currentValue -}}
         {{- else -}}
             {{- $remainingParameters := rest $parameters -}}
             {{- $recursiveArgs := prepend $remainingParameters $values -}}
             {{- include "eric-oss-pf-apex.firstOptional" $recursiveArgs -}}
         {{- end -}}
     {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-oss-pf-apex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Chart version.
*/}}
{{- define "eric-oss-pf-apex.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-oss-pf-apex.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "eric-oss-pf-apex-configmap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "eric-oss-pf-apex-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create release name used for cluster role.
*/}}
{{- define "eric-oss-pf-apex.release.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-oss-pf-apex.registryUrl" -}}
{{- if .Values.imageCredentials.registry -}}
{{- if .Values.imageCredentials.registry.url -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- else if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
""
{{- end -}}
{{- else if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
""
{{- end -}}
{{- end -}}

{{/*
Create Ericsson product app.kubernetes.io info
*/}}
{{- define "eric-oss-pf-apex.kubernetes-io-info" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Create Ericsson Product Info
*/}}
{{- define "eric-oss-pf-apex.eric-product-info" -}}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: "CNX/102/02X"
ericsson.com/product-revision: "NUM"
{{- end}}

{{/*
The apexImage path (DR-D1121-067)
*/}}
{{- define "eric-oss-pf-apex.mainImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.apexImage.registry -}}
    {{- $repoPath := $productInfo.images.apexImage.repoPath -}}
    {{- $name := $productInfo.images.apexImage.name -}}
    {{- $tag := $productInfo.images.apexImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.apexImage -}}
            {{- if .Values.imageCredentials.apexImage.registry -}}
                {{- if .Values.imageCredentials.apexImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.apexImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if .Values.imageCredentials.apexImage.repoPath -}}
                {{- $repoPath = .Values.imageCredentials.apexImage.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.images -}}
        {{- if .Values.images.apexImage -}}
            {{- if .Values.images.apexImage.name -}}
                {{- $name = .Values.images.apexImage.name -}}
            {{- end -}}
            {{- if .Values.images.apexImage.tag -}}
                {{- $tag = .Values.images.apexImage.tag -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The apexImage pull policy
*/}}
{{- define "eric-oss-pf-apex.imagePullPolicy" -}}
    {{- include "eric-oss-pf-apex.firstOptional" (list .Values "imageCredentials.apexImage.registry.imagePullPolicy" "global.registry.imagePullPolicy") | default "IfNotPresent" -}}
{{- end -}}

{{/*
The keycloakImage path (DR-D1121-067)
*/}}
{{- define "eric-oss-pf-apex.keycloakImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.keycloakImage.registry -}}
    {{- $repoPath := $productInfo.images.keycloakImage.repoPath -}}
    {{- $name := $productInfo.images.keycloakImage.name -}}
    {{- $tag := $productInfo.images.keycloakImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.keycloakImage -}}
            {{- if .Values.imageCredentials.keycloakImage.registry -}}
                {{- if .Values.imageCredentials.keycloakImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.keycloakImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.keycloakImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.keycloakImage.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The name of the cluster role used during openshift deployments.
This helper is provided to allow use of the new global.security.privilegedPolicyClusterRoleName if set, otherwise
use the previous naming convention of <release_name>-allowed-use-privileged-policy for backwards compatibility.
*/}}
{{- define "eric-oss-pf-apex.privileged.cluster.role.name" -}}
  {{- if hasKey (.Values.global.security) "privilegedPolicyClusterRoleName" -}}
    {{ .Values.global.security.privilegedPolicyClusterRoleName }}
  {{- else -}}
    {{ template "eric-oss-pf-apex.release.name" . }}-allowed-use-privileged-policy
  {{- end -}}
{{- end -}}
