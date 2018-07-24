package main

import (
	"encoding/base64"

	"github.com/go-interledger/cryptoconditions"

	"os"
)

var f = "pGSAIPBTpGBqs19vwZOOV7DYwi4ys0hJlIjuGs_OgaETQiI2gUB17zVWQSb3SqXOxckOAdLEEPgY7nwy0bfKc42ejHIr6QBmXyuw826R8aGaBnXOnCK5GML4cu5tYE3_96Vm9-AD"

func DecodeURI(URI string) (cryptoconditions.Fulfillment, error) {
	bts, err := base64.URLEncoding.DecodeString(URI)
	if err != nil {
		return nil, err
	}

	f, err := cryptoconditions.DecodeFulfillment(bts)
	if err != nil {
		return nil, err
	}
	return f, nil
}

func EncodeFulfillment(f cryptoconditions.Fulfillment) (*string, error) {
	bts, err := f.Encode()
	if err != nil {
		return nil, err
	}
	s := base64.URLEncoding.EncodeToString(bts)
	return &s, nil
}

func main() {
	i := 0
	for i < 100000 {
		i += 1
		decoded, err := DecodeURI(f)
		if err != nil {
			os.Exit(1)
		}
		_, err = EncodeFulfillment(decoded)
		if err != nil {
			os.Exit(1)
		}
	}
}