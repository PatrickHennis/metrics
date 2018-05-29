#!/bin/bash

memcall="$(/Applications/ZENCashWallet.app/Contents/Java/zen-cli getrawmempool)"
time="$(date +%s)"
while IFS=',' read -ra ADDR; do
     for i in "${ADDR[@]}"; do
         if [[ $i == *"\""* ]]; then
           echo "${i:3:64}, $time">> mempool.txt
         fi
     done
done <<< "$memcall"

#/Applications/ZENCashWallet.app/Contents/Java/zen-cli decoderawtransaction $(/Applications/ZENCashWallet.app/Contents/Java/zen-cli getrawtransaction $tx)
