# For test helm chart

## Add chart to repo

add helmchart new version
```bash
helm package ./traefik-ingress --destination ./docs
helm package ./zookeeper --destination ./docs
helm package ./app --destination ./docs
```

update `index.yaml`
```bash
helm repo index ./docs --url https://42wms.github.io/chart-test
```

## Use charts

add repo
```bash
helm repo add chart-test https://42wms.github.io/chart-test
helm repo update
helm search repo chart-test
```

install chart
```bash
helm install my-traefik chart-test/traefik-ingress
helm install my-zookeeper chart-test/zookeeper
```