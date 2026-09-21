.PHONY: local local-down hard attacks checkov kind-up kind-down aws-init aws-plan aws-apply aws-destroy

local:
    docker compose up --build

local-down:
    docker compose down

hard:
    docker compose up --build hardened

attacks:
    BASE=http://127.0.0.1:8080 ./scripts/attack-paths.sh

attacks-hard:
    BASE=http://127.0.0.1:8081 ./scripts/attack-paths-hard.sh

checkov:
    docker run --rm -v "$(PWD):/src" bridgecrew/checkov:latest \
      -d /src/infra --config-file /src/.checkov.yml

kind-up:
    kind create cluster --name secops-lab --config k8s/kind.yaml || true
    kubectl apply -f k8s/demo-app/deployment.yaml

kind-down:
    kind delete cluster --name secops-lab

aws-init:
    cd infra && terraform init

aws-plan:
    cd infra && terraform plan

aws-apply:
    cd infra && terraform apply

aws-destroy:
    cd infra && terraform destroy
