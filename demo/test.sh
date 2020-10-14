#!/bin/bash
exitTestFail() {
  echo "$1"
  kubectl describe pvc
  exit 1
}

# pre-generated token added to secret
token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InVzZXJAb3BlbnN0b3JhZ2UuaW8iLCJleHAiOjE3NTMxNDA0NDcsImdyb3VwcyI6WyIqIl0sImlhdCI6MTU5NTQ2MDQ0NywiaXNzIjoib3BlbnN0b3JhZ2UuaW8iLCJuYW1lIjoidXNlciIsInJvbGVzIjpbInN5c3RlbS51c2VyIl0sInN1YiI6InVzZXJAb3BlbnN0b3JhZ2UuaW8ifQ.41yebvGhSUlks4_perFh0sORmGnpulEML-7plFa0WWE
kubectl create secret generic token-secret --from-literal=auth-token=$token
kubectl get secret token-secret || exitTestFail "failed to create token secrets"

# Create Storage Class
kubectl apply -f demo/e2e/storageclass.yaml || exitTestFail "failed to apply storageclass yaml"
kubectl get storageclass openstorage-sc || exitTestFail "failed to create storageclass"

# Create PVC
kubectl apply -f demo/e2e/pvc.yaml || exitTestFail "failed to apply PVC yaml"
sleep 15
kubectl get pvc openstorage-pvc | grep Bound || exitTestFail "PVC not bound after 15 seconds"

# Use PVC with MySQL deployment
kubectl apply -f demo/e2e/mysql.yaml || exitTestFail "failed to apply deployment yaml"
