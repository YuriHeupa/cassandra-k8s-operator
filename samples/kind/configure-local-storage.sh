#!/bin/bash

KUBE_NODES=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}')
NB_PV=5

if [ "$1" == "create" ]; then

    kubectl apply -f samples/kind/storageclass-local-storage.yaml

    for n in $KUBE_NODES; do
        echo $n
        for i in `seq -w 1 $NB_PV`; do
            echo docker exec -ti $n bash -c "mkdir -p /kind/local-storage/pv$i"
            docker exec -ti $n bash -c "mkdir -p /kind/local-storage/pv$i"
            docker exec -ti $n bash -c "mount -t tmpfs pv$i /kind/local-storage/pv$i"
        done
    done

    kubectl create namespace local-provisioner
    kubectl apply -f samples/kind/provisioner_generated.yaml

fi

if [ "$1" == "delete" ]; then
        for n in $KUBE_NODES; do
            echo $n
            for i in `seq -w 1 $NB_PV`; do
                kubectl delete pv local-pv-$n-$i
            done
        done
fi
