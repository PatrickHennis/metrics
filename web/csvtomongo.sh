#!/bin/bash

echo "$(mongoimport --db data --collection txs --type csv --file '../data.csv' --numInsertionWorkers 5)"
