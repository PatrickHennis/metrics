#!/bin/bash

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
