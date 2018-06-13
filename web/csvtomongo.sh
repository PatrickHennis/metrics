#!/bin/bash

echo "$(mongoimport --db data --collection txs --type csv --file '../metrics.csv' --headerline --numInsertionWorkers 5)"
echo "txid,amount,creation_time,inclusion_time,delta,number_inputs,number_outputs" > ../metrics.csv
