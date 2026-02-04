from __future__ import print_function
import os
import sys
import logging
import random

from flask import Flask, Blueprint, request, jsonify

app = Flask(__name__)
bp = Blueprint(__name__, 'api', url_prefix='/api/v4')


@bp.route('/runners', methods=['POST'])
def register_runner():
    logging.info("Got register_runner request: {!r}".format(request.data))
    req = request.json
    res = {}

    token = req['token']
    if token.isalnum() and token.islower():
        res['token'] = "{}{}".format(token.upper(), random.randint(100, 999))
        status = 201
    elif token.isalnum() and token.isupper():
        status = 403
    else:
        status = 400

    return jsonify(res), status


@bp.route('/runners/verify', methods=['POST'])
def verify_runner():
    logging.info("Got verify_runner request: {!r}".format(request.data))
    req = request.json
    res = {}

    token = req['token']
    if token.isalnum() and token.isupper():
        status = 200
    elif token.isalnum() and token.islower():
        status = 403
    else:
        status = 400

    return jsonify(res), status


app.register_blueprint(bp)


if __name__ == '__main__':
    port = int(sys.argv[2])

    logging.basicConfig(level=logging.DEBUG)

    app.run(port=port, host="0.0.0.0", debug=True)
