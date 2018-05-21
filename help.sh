#!/bin/bash
while IFS='' read -r line || [[ -n "$line" ]]; do
         address=$(echo $line | awk '{printf$1}')
         out=$(zen-cli z_getbalance $address)
         if [ $out != "0.00000000" ]; then
           echo
           echo $address
           zen-cli z_getbalance $address
           echo
       fi
done < addresses.txt
