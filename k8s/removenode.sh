#!/bin/bash

while getopts ":a:" opt; do
  case $opt in
    a)
      arg="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

echo "Node to remove: $arg"
kubectl drain $arg --ignore-daemonsets
kubectl delete node $arg
