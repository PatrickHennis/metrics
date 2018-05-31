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


write_pool () { # reads mempool.txt and retrieves all data to write to csv, clears mempool.txt after
  filename="mempool.txt"
  error="error code: -5"
  while read -r line
  do
      txid="${line:0:64}"
      creation_time="${line:66}"
      blocktime="$(/Applications/ZENCashWallet.app/Contents/Java/zen-cli getrawtransaction $txid 1 | sed -n 's/.*\"blocktime\": //p')"
      amounts="$(/Applications/ZENCashWallet.app/Contents/Java/zen-cli getrawtransaction $txid 1 | sed -n 's/.*\"value\"://p')"
      search=","
      amount="${amounts%%$search*}"
      delta=$((blocktime - $creation_time))
      string="$txid, $amount, $creation_time, $blocktime, $delta"
      echo ${string} | grep --quiet "${error}"

      if [ $? = 1 ]; then
        if [ -n "$amount" ]; then
          if [ -n "$blocktime" ]; then
            echo $string >> metrics.csv
          fi
        fi
      fi
  done < "$filename"
  > $filename
}


write_send() { # takes the result of send () and writes data to metrics.csv
  echo "$(python3 metrics.py)"
  filename="temp.txt"
  error="error code: -5"
  while read -r line
  do
      txid="${line:0:64}"
      amount="${line:65:6}"
      creation_time="${line:72}"
      blocktime="$(/Applications/ZENCashWallet.app/Contents/Java/zen-cli getrawtransaction $txid 1 | sed -n 's/.*\"blocktime\": //p')"
      delta=$((blocktime - $creation_time))
      string="$txid, $amount, $creation_time, $blocktime, $delta"
      echo ${string} | grep --quiet "${error}"

      if [ $? = 1 ]; then
        if [ -n "$amount" ]; then
          if [ -n "$blocktime" ]; then
            echo $string >> metrics.csv
          fi
        fi
      fi
  done < "$filename"
  > $filename
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
    write_pool
    send

    starthour="$(date +%H)"
    sleep 1
  fi
done
