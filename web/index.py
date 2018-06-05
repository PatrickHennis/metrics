from flask import Flask, render_template, request, redirect
import os
from pymongo import MongoClient

def connect():
    connection = MongoClient('localhost', 27017)
    return connection

app = Flask(__name__)
handle = connect()

@app.route("/index" ,methods=['GET'])
@app.route("/", methods=['GET'])
def index():
    txs = []
    cursor = handle.data.txs.find({})
    for document in cursor:
        txs.append(document)
    return render_template('index.html', txs=txs)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))

    app.run(host='0.0.0.0', port=port, debug=True)
