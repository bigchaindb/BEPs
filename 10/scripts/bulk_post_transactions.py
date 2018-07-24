import argparse
import threading

from datetime import datetime

from bigchaindb.common.crypto import generate_key_pair
from bigchaindb.models import Transaction
from bigchaindb.tendermint.lib import BigchainDB


class TransactionThread(threading.Thread):

    def __init__(self, *args, **kwargs):
        self.transactions_per_thread = kwargs['transactions_per_thread']
        self.mode = kwargs['mode']
        return super().__init__()

    def run(self):

        b = BigchainDB()

        bicycle = {
            'data': {'pripid': '88273712778381','reg_no':'88273712778381','origin_entname':'xxxxxxxxxxx'},
        }
        utctp = datetime.now().utcnow().timestamp()
        metadata = {'date': utctp }

        for i in range(self.transactions_per_thread):
            alice = generate_key_pair()

            prepared_creation_tx = Transaction.create([alice.public_key],
                                                      [([alice.public_key], 1)],
                                                      metadata=metadata,
                                                      asset=bicycle,).sign([alice.private_key])

            res = b.write_transaction(prepared_creation_tx, f'broadcast_tx_{self.mode}')
            assert res[0] == 202


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--threads', default=10, type=int,
                        help='The number of threads to spawn.')
    parser.add_argument('-tpt', '--transactions-per-thread', default=10, type=int,
                        help='The number of transactions to create in every thread.')
    parser.add_argument('-m', '--mode', default='async', type=str,
                        help='The transaction mode - async or commit.')

    args = parser.parse_args()

    for i in range(args.threads):
        t = TransactionThread(transactions_per_thread=args.transactions_per_thread, mode=args.mode)
        t.start()
