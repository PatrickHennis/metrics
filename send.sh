#!/bin/bash

zsrc="ztcLKgUC9JrN1519ZjXmNy9wXAKnVcFE9tX"
zto="ztftydJRhDSXvctekQB7e1BRubfhnFWFdgS"
zamount="0.0001"

sdm="$(/home/devel/zen/src/zen-cli z_sendmany "$zsrc" "[{\"amount\": $zamount, \"address\": \"$zto\"},
                            {\"amount\": $zamount, \"address\": \"$zto\"},
                            {\"amount\": $zamount, \"address\": \"$zto\"},
                            {\"amount\": $zamount, \"address\": \"$zto\"},
                            {\"amount\": $zamount, \"address\": \"$zto\"},
                            {\"amount\": $zamount, \"address\": \"$zto\"},
                            {\"amount\": $zamount, \"address\": \"$zto\"},
                            {\"amount\": $zamount, \"address\": \"$zto\"},
                            {\"amount\": $zamount, \"address\": \"$zto\"},
                            {\"amount\": $zamount, \"address\": \"$zto\"}]")" # 10 times

str="\"status\": \"success\","

echo
if [[ $sdm = *opid* ]]; then
  opr="$(/home/devel/zen/src/zen-cli z_getoperationresult)"
  if [[ "$opr" == *"$str"* ]]; then
    echo "$opr"
    echo "success"
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
