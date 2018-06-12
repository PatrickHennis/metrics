#!/bin/bash

mempool () { # function to scrape transactions from mempool
  memcall="$(zen-cli getrawmempool)"
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
  write=0
  while read -r line
  do
    txid="${line:0:64}"

    creation_time="${line:66}"
    blocktime="$(zen-cli getrawtransaction $txid 1 | sed -n 's/.*\"blocktime\": //p')"
    delta=$((blocktime - $creation_time))

    amounts="$(zen-cli getrawtransaction $txid 1 | sed -n 's/.*\"value\"://p')"
    search=","
    amount="${amounts%%$search*}"


    inputs="$(zen-cli getrawtransaction $txid 1)"
    vout="vout"
    NumberOfMatches=$(echo "$string" | tr " " "\n" | grep -c "$vout")
    num=$(( NumberOfMatches - 1 ))
    if (( num < 0 )); then
      num=0
    fi

    outputs="$(zen-cli getrawtransaction $txid 1)"
    n="\"n\":"
    numofoutputs=$(echo "$outputs" | tr " " "\n" | grep -c "$n")
    outnum=$(( numofoutputs - 1 ))
    if (( outnum < 0 )); then
      num=0
    fi

    string="$txid, $amount, $creation_time, $blocktime, $delta, $num, $outnum"
    echo ${string} | grep --quiet "${error}"

      if [ $? = 1 ]; then
        if [ -n "$amount" ]; then
          if [ -n "$blocktime" ]; then
            echo $string >> metrics.csv
            write=1
          fi
        fi
      fi
  done < "$filename"
  if [[ $write = 1 ]]; then
    > $filename
  fi
}


write_send() { # takes the result of send () and writes data to metrics.csv
  echo "$(python3 metrics.py)"
  filename="temp.txt"
  error="error code: -5"
  write=0
  while read -r line
  do
      txid="${line:0:64}"

      creation_time="${line:66}"
      blocktime="$(zen-cli getrawtransaction $txid 1 | sed -n 's/.*\"blocktime\": //p')"
      delta=$((blocktime - $creation_time))

      amounts="$(zen-cli getrawtransaction $txid 1 | sed -n 's/.*\"value\"://p')"
      search=","
      amount="${amounts%%$search*}"


      inputs="$(zen-cli getrawtransaction $txid 1)"
      vout="vout"
      NumberOfMatches=$(echo "$string" | tr " " "\n" | grep -c "$vout")
      num=$(( NumberOfMatches - 1 ))

      outputs="$(zen-cli getrawtransaction $txid 1)"
      n="\"n\":"
      numofoutputs=$(echo "$outputs" | tr " " "\n" | grep -c "$n")
      outnum=$(( numofoutputs - 1 ))

      string="$txid, $amount, $creation_time, $blocktime, $delta, $num, $outnum"
      echo ${string} | grep --quiet "${error}"

      if [ $? = 1 ]; then
        if [ -n "$amount" ]; then
          if [ -n "$blocktime" ]; then
            echo $string >> metrics.csv
            write=1
          fi
        fi
      fi
  done < "$filename"
  if [[ $write = 1 ]]; then
    > $filename
  fi
}

echo "txid,amount,creation_time,inclusion_time,delta,number_inputs,number_outputs" > metrics.csv

starthour="$(date +%H)"
startmin="$(date +%M)"
while :
do
  diff="$((10#$(date +%M) - startmin ))"
  echo $diff
  if [[ $diff -lt 0 ]]; then
    startmin="$(date +%M)"
  elif [[ $diff -lt 15 ]]; then # check to see if same hour as when started
    # runs constantly throughout hour
    mempool
    echo "mempool"
    sleep 1
  elif [[ $starthour != $(date +%H) ]]; then
    write_send
    send

    starthour="$(date +%H)"
    sleep 1
    echo "elif"
  else # update time
    # runs hourly
    write_pool

    echo "else"
    startmin="$(date +%M)"
    sleep 1
  fi
done
