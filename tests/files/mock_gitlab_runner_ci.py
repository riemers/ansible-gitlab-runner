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
    pid = str(os.getpid())
    pidfile = os.path.expanduser(sys.argv[1])

    if os.path.isfile(pidfile):
        print("{} already exists, exiting".format(pidfile))
        sys.exit(1)

    port = int(sys.argv[2])

    with open(pidfile, 'w') as f:
        f.write(pid)

    logging.basicConfig(level=logging.DEBUG)

    try:
        app.run(port=port, debug=False)
    finally:
        os.unlink(pidfile)
