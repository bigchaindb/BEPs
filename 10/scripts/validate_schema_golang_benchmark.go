package main

import (
	"github.com/xeipuuv/gojsonschema"

	"os"
)

var COMMONSCHEMA = `{"$schema": "http://json-schema.org/draft-04/schema#", "type": "object", "additionalProperties": false, "title": "Transaction Schema", "required": ["id", "inputs", "outputs", "operation", "metadata", "asset", "version"], "properties": {"id": {"anyOf": [{"$ref": "#/definitions/sha3_hexdigest"}, {"type": "null"}]}, "operation": {"$ref": "#/definitions/operation"}, "asset": {"$ref": "#/definitions/asset"}, "inputs": {"type": "array", "title": "Transaction inputs", "items": {"$ref": "#/definitions/input"}}, "outputs": {"type": "array", "items": {"$ref": "#/definitions/output"}}, "metadata": {"$ref": "#/definitions/metadata"}, "version": {"type": "string", "pattern": "^2\\.0$"}}, "definitions": {"offset": {"type": "integer", "minimum": 0}, "base58": {"pattern": "[1-9a-zA-Z^OIl]{43,44}", "type": "string"}, "public_keys": {"anyOf": [{"type": "array", "items": {"$ref": "#/definitions/base58"}}, {"type": "null"}]}, "sha3_hexdigest": {"pattern": "[0-9a-f]{64}", "type": "string"}, "uuid4": {"pattern": "[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}", "type": "string"}, "operation": {"type": "string", "enum": ["CREATE", "TRANSFER"]}, "asset": {"type": "object", "additionalProperties": false, "properties": {"id": {"$ref": "#/definitions/sha3_hexdigest"}, "data": {"anyOf": [{"type": "object", "additionalProperties": true}, {"type": "null"}]}}}, "output": {"type": "object", "additionalProperties": false, "required": ["amount", "condition", "public_keys"], "properties": {"amount": {"type": "string", "pattern": "^[0-9]{1,20}$"}, "condition": {"type": "object", "additionalProperties": false, "required": ["details", "uri"], "properties": {"details": {"$ref": "#/definitions/condition_details"}, "uri": {"type": "string", "pattern": "^ni:///sha-256;([a-zA-Z0-9_-]{0,86})[?](fpt=(ed25519|threshold)-sha-256(&)?|cost=[0-9]+(&)?|subtypes=ed25519-sha-256(&)?){2,3}$"}}}, "public_keys": {"$ref": "#/definitions/public_keys"}}}, "input": {"type": "object", "additionalProperties": false, "required": ["owners_before", "fulfillment"], "properties": {"owners_before": {"$ref": "#/definitions/public_keys"}, "fulfillment": {"anyOf": [{"type": "string", "pattern": "^[a-zA-Z0-9_-]*$"}, {"$ref": "#/definitions/condition_details"}]}, "fulfills": {"anyOf": [{"type": "object", "additionalProperties": false, "required": ["output_index", "transaction_id"], "properties": {"output_index": {"$ref": "#/definitions/offset"}, "transaction_id": {"$ref": "#/definitions/sha3_hexdigest"}}}, {"type": "null"}]}}}, "metadata": {"anyOf": [{"type": "object", "additionalProperties": true, "minProperties": 1}, {"type": "null"}]}, "condition_details": {"anyOf": [{"type": "object", "additionalProperties": false, "required": ["type", "public_key"], "properties": {"type": {"type": "string", "pattern": "^ed25519-sha-256$"}, "public_key": {"$ref": "#/definitions/base58"}}}, {"type": "object", "additionalProperties": false, "required": ["type", "threshold", "subconditions"], "properties": {"type": {"type": "string", "pattern": "^threshold-sha-256$"}, "threshold": {"type": "integer", "minimum": 1, "maximum": 100}, "subconditions": {"type": "array", "items": {"$ref": "#/definitions/condition_details"}}}}]}}}`

var CREATESCHEMA = `{"$schema": "http://json-schema.org/draft-04/schema#", "type": "object", "title": "Transaction Schema - CREATE specific constraints", "required": ["asset", "inputs"], "properties": {"asset": {"additionalProperties": false, "properties": {"data": {"anyOf": [{"type": "object", "additionalProperties": true}, {"type": "null"}]}}, "required": ["data"]}, "inputs": {"type": "array", "title": "Transaction inputs", "maxItems": 1, "minItems": 1, "items": {"type": "object", "required": ["fulfills"], "properties": {"fulfills": {"type": "null"}}}}}}`

var TXJSON = `{"inputs": [{"owners_before": ["HB8pchV2m2kUYG261VLooVyFtRy7oa8zYM5bp8LydtN9"], "fulfills": null, "fulfillment": "pGSAIPBTpGBqs19vwZOOV7DYwi4ys0hJlIjuGs_OgaETQiI2gUB17zVWQSb3SqXOxckOAdLEEPgY7nwy0bfKc42ejHIr6QBmXyuw826R8aGaBnXOnCK5GML4cu5tYE3_96Vm9-AD"}], "outputs": [{"public_keys": ["HB8pchV2m2kUYG261VLooVyFtRy7oa8zYM5bp8LydtN9"], "condition": {"details": {"type": "ed25519-sha-256", "public_key": "HB8pchV2m2kUYG261VLooVyFtRy7oa8zYM5bp8LydtN9"}, "uri": "ni:///sha-256;jgEMKhUiWp14Ta60Znk1VnQQXyVHAKyH53BCes_ts34?fpt=ed25519-sha-256&cost=131072"}, "amount": "1"}], "operation": "CREATE", "metadata": {"date": 1527499149.748151}, "asset": {"data": {"data": {"pripid": "88273712778381", "reg_no": "88273712778381", "origin_entname": "xxxxxxxxxxx"}}}, "version": "2.0", "id": "1132758e481701f615d88105dd8eff9cb30a782fe5b5396bbe93c011902d0d48"}`

func main() {
	commonSchemaLoader := gojsonschema.NewStringLoader(COMMONSCHEMA)
	createSchemaLoader := gojsonschema.NewStringLoader(CREATESCHEMA)

	commonSchema, err := gojsonschema.NewSchema(commonSchemaLoader)
	if err != nil {
		os.Exit(1)
	}
	createSchema, err := gojsonschema.NewSchema(createSchemaLoader)
	if err != nil {
		os.Exit(1)
	}
	tx := gojsonschema.NewStringLoader(TXJSON)

	i := 0
	for i < 100000 {
		i++
		commonSchema.Validate(tx)
		createSchema.Validate(tx)
	}
}