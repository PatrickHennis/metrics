# metrics

## use
to gather data for metrics on transaction inclusion in blocks, run `metrics.sh`
which gathers transactions from the mempool and once per hour creates transactions
with various input amounts. once per hour the transactions are checked to see if
they were included in a block and gathers appropriate information and  compiles
all in `metrics.csv`.

`metrics.py` is called from `metrics.sh` to ease the parsing of json data from
the output of `z_getoperationresult`.

`send.sh` is used to send transactions with multiple inputs to the same address.
it requires [this patch](https://github.com/zcash/zcash/issues/2955#issuecomment-366314590) to run correctly

## setup
in the `send()` function in `metrics.sh` the `zfrom` and `zto` addresses need to
be set accordingly

the `zen-cli` path may also need to be configured depending on system

## requirements
`python3`
