from bigchaindb.common.schema import validate_transaction_schema

tx = {'inputs': [{'owners_before': ['HB8pchV2m2kUYG261VLooVyFtRy7oa8zYM5bp8LydtN9'], 'fulfills': None, 'fulfillment': 'pGSAIPBTpGBqs19vwZOOV7DYwi4ys0hJlIjuGs_OgaETQiI2gUB17zVWQSb3SqXOxckOAdLEEPgY7nwy0bfKc42ejHIr6QBmXyuw826R8aGaBnXOnCK5GML4cu5tYE3_96Vm9-AD'}], 'outputs': [{'public_keys': ['HB8pchV2m2kUYG261VLooVyFtRy7oa8zYM5bp8LydtN9'], 'condition': {'details': {'type': 'ed25519-sha-256', 'public_key': 'HB8pchV2m2kUYG261VLooVyFtRy7oa8zYM5bp8LydtN9'}, 'uri': 'ni:///sha-256;jgEMKhUiWp14Ta60Znk1VnQQXyVHAKyH53BCes_ts34?fpt=ed25519-sha-256&cost=131072'}, 'amount': '1'}], 'operation': 'CREATE', 'metadata': {'date': 1527499149.748151}, 'asset': {'data': {'data': {'pripid': '88273712778381', 'reg_no': '88273712778381', 'origin_entname': 'xxxxxxxxxxx'}}}, 'version': '2.0', 'id': '1132758e481701f615d88105dd8eff9cb30a782fe5b5396bbe93c011902d0d48'}

for _ in range(100000):
    validate_transaction_schema(tx)
