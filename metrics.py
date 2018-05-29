import json
import urllib.request


class AppURLopener(urllib.request.FancyURLopener):
    version = "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.69 Safari/537.36"


class BlockData:
    def __init__(self, txid, amount, creation_time):
        self.txid = txid
        self.amount = amount
        self.creation_time = creation_time

    def calc_delta(self, inclusion_time):
        self.inclusion_time = inclusion_time
        self.time_delta = abs(inclusion_time - self.creation_time)


data_points = []

with open("metrics.txt") as f:
    for line in f:
        while True:
            try:
                jfile = json.loads(line)
                break
            except ValueError:
                line += next(f)

        txid = jfile[0]['result']['txid']
        amount = jfile[0]['params']['amounts'][0]['amount']
        time = jfile[0]['creation_time']
        bd = BlockData(txid, amount, time)

        id = "4eae70898c20f5216d8523e7e7e24d1720ad0ae8b7ed598fc6e4dd371125ab36"
        url = 'https://explorer.zensystem.io/insight-api-zen/tx/' + id # change to txid when ran on mainnet
        urllib._urlopener = AppURLopener()
        urllib._urlopener.retrieve(url, "data.txt")

        with open('data.txt') as d:
            data = json.load(d)

        bd.calc_delta(data["blocktime"])

        data_points.append(bd)

with open("mempool.txt") as m:
    for line in m:
        text = [x.strip() for x in line.split(',')]
        txid = text[0]
        time = text[1]

        url = 'https://explorer.zensystem.io/insight-api-zen/tx/' + txid
        urllib._urlopener = AppURLopener()
        urllib._urlopener.retrieve(url, "data.txt")

        with open('data.txt') as d:
            data = json.load(d)

        amount = data["valueIn"]
        blocktime = data["blocktime"]

        bd = BlockData(txid, amount, time)
        bd.calc_delta(blocktime)
        data_points.append(bd)


file = open("data.csv","w")

file.write("transaction id,amount,creation time, inclusion time, time delta")

for a in data_points:
    file.write(a.txid + "," + str(a.amount) + "," + str(a.creation_time) + "," + str(a.inclusion_time) + "," + str(a.time_delta) + "\n")

file.close()
