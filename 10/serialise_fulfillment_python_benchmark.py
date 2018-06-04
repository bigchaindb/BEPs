from cryptoconditions import Fulfillment

fulfillment = 'pGSAIPBTpGBqs19vwZOOV7DYwi4ys0hJlIjuGs_OgaETQiI2gUB17zVWQSb3SqXOxckOAdLEEPgY7nwy0bfKc42ejHIr6QBmXyuw826R8aGaBnXOnCK5GML4cu5tYE3_96Vm9-AD'

for _ in range(100000):
    Fulfillment.from_uri(fulfillment).serialize_uri()
