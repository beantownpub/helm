apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: istio
spec:
  generators:
    - list:
        elements:
          - branch: main
            cluster: in-cluster
            url: https://kubernetes.default.svc

  template:
    metadata:
      name: 'istio-{{cluster}}'
      annotations:
        argocd.argoproj.io/manifest-generate-paths: /istio
    spec:
      source:
        path: istio/
        repoURL: git@github.com:beantownpub/helm.git
        targetRevision: '{{branch}}'
        helm:
          releaseName: istio
          valueFiles:
            - values.yaml
      destination:
        namespace: istio-system
        server: '{{url}}'
      ignoreDifferences:
        - jsonPointers:
            - /metadata/labels
          kind: Secret
      project: '{{cluster}}'
      syncPolicy: {}
        # automated:
        #   selfHeal: false
