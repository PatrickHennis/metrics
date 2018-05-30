# metrics

## use
to gather data for metrics, run `metrics.sh` which contains two functions,
`mempool()` and `send()`. `mempool()` collects transaction id's and time from the
mempool. `send()` sends transactions containing inputs of `0.0001` in amount of
`0.0001`, `0.0049`, and `0.0199`. `mempool()` runs every second checking for new
transactions in the mempool and `send()` runs once per hour.

after running `metrics.sh` for a while, two text files will be created, `metrics.txt`
and `mempool.txt`. `metrics.py` is called from `metrics.sh` and takes the data
from both files and and retrieves data from the insight api and creates `data.csv`

## setup
in the `send()` function in `metrics.sh` the `zfrom` and `zto` addresses need to
be set accordingly
