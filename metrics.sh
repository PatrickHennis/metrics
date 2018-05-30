#!/bin/bash

mempool () { # function to scrape transactions from mempool
  memcall="$(/Applications/ZENCashWallet.app/Contents/Java/zen-cli getrawmempool)"
  time="$(date +%s)"
  while IFS=',' read -ra ADDR; do
       for i in "${ADDR[@]}"; do
           if [[ $i == *"\""* ]]; then
             if ! grep -q "${i:3:64}" mempool.txt; then
               echo "${i:3:64}, $time">> mempool.txt
             fi
           fi
       done
  done <<< "$memcall"
}


send () { # function to create transactions with multiple inputs
  zfrom="ztftydJRhDSXvctekQB7e1BRubfhnFWFdgS"
  zto="ztcLKgUC9JrN1519ZjXmNy9wXAKnVcFE9tX"
  ztwo="0.0001"
  zfifty="0.0049"
  zmany="0.0199"


  sendtwo="$(zen-cli z_sendmany "$zfrom" "[{\"amount\": $ztwo, \"address\": \"$zto\"}]")"
  sendfifty="$(zen-cli z_sendmany "$zfrom" "[{\"amount\": $zfifty, \"address\": \"$zto\"}]")"
  sendmany="$(zen-cli z_sendmany "$zfrom" "[{\"amount\": $zmany, \"address\": \"$zto\"}]")"

  success="\"status\": \"success\","

  echo
  if [[ $sendtwo = *opid* ]]; then
    opr="$(zen-cli z_getoperationresult)"
    if [[ "$opr" == *"$success"* ]]; then
      echo "$opr" >> metrics.txt
      echo "two success"
    else
      echo
      echo "-------------"
      echo "failed"
      echo "$opr"
      echo "-------------"
      echo
    fi
  else
    echo "transaction malformed"
  fi
  echo
  echo
  if [[ $sendfifty = *opid* ]]; then
    opr="$(zen-cli z_getoperationresult)"
    if [[ "$opr" == *"$success"* ]]; then
      echo "$opr" >> metrics.txt
      echo "fifty success"
    else
      echo
      echo "-------------"
      echo "failed"
      echo "$opr"
      echo "-------------"
      echo
    fi
  else
    echo "transaction malformed"
  fi
  echo
  echo
  if [[ $sendmany = *opid* ]]; then
    opr="$(zen-cli z_getoperationresult)"
    if [[ "$opr" == *"$success"* ]]; then
      echo "$opr" >> metrics.txt
      echo "many success"
    else
      echo
      echo "-------------"
      echo "failed"
      echo "$opr"
      echo "-------------"
      echo
    fi
  else
    echo "transaction malformed"
  fi
  echo
}



starthour="$(date +%H)"
while :
do
  if [[ $starthour == $(date +%H) ]]; then # check to see if same hour as when started
    # runs constantly throughout hour
    mempool

    sleep 1
  else # update time
    # runs hourly
    echo "$(python3 metrics.py)"
    send

    starthour="$(date +%H)"
    sleep 1
  fi
done
