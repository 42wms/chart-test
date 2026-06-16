# For test helm chart

## Add chart to repo

Add helmchart new version.
```bash
helm package ./traefik-ingress --destination ./docs
helm package ./zookeeper --destination ./docs
helm package ./app --destination ./docs
```

Update `index.yaml`.
```bash
helm repo index ./docs --url https://42wms.github.io/chart-test
```

## Use charts

Add repo.
```bash
helm repo add chart-test https://42wms.github.io/chart-test
helm repo update
helm search repo chart-test
```

Install chart.
```bash
helm install my-traefik chart-test/traefik-ingress
helm install my-zookeeper chart-test/zookeeper
```

## Testing chart template

Create `values-test.yaml` for testing chart template.

Get template.
```bash
helm template my-traefik-ingress ./traefik-ingress/ -n my-ns-traefik-ingress -f ./traefik-ingress/values-test.yaml --debug > temp-ti.yaml
helm template my-zookeeper ./zookeeper/ -n my-ns-zookeeper -f ./zookeeper/values-test.yaml --debug > temp-zk.yaml
helm template my-app ./app/ -n my-ns-app -f ./app/values-test.yaml --debug > temp-app.yaml
```
