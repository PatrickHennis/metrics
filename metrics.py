import json

class BlockData:
    def __init__(self, txid, amount, creation_time):
        self.txid = txid
        self.amount = amount
        self.creation_time = creation_time


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

        data_points.append(bd)


file = open("temp.txt","w")

for a in data_points:
    file.write(a.txid + "," + str(a.amount) + "," + str(a.creation_time) + "\n")

file.close()
