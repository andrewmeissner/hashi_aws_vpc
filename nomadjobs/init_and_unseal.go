package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

var (
	baseURL = "http://%s:8200/v1%s"
)

type initResponse struct {
	Keys       []string `json:"keys"`
	KeysBase64 []string `json:"keys_base64"`
	RootToken  string   `json:"root_token"`
}

type initPayload struct {
	Shares    int64 `json:"secret_shares"`
	Threshold int64 `json:"secret_threshold"`
}

type unsealPayload struct {
	Key string `json:"key"`
}

type unsealResponse struct {
	Sealed    bool   `json:"sealed"`
	Threshold int64  `json:"t"`
	Shares    int64  `json:"n"`
	Progress  int64  `json:"progress"`
	Version   string `json:"version"`
}

func main() {
	ips := os.Args[1:]

	if len(ips) != 3 {
		panic("Need 3 ips")
	}

	if initRes := initVault(ips[0]); initRes != nil {
		unsealVaults(ips, initRes)
		bs, err := json.MarshalIndent(initRes, "", "\t")
		check(err)
		f, err := os.Create("vaultCreds.json")
		check(err)
		defer f.Close()
		_, err = f.Write(bs)
		check(err)
	}

	fmt.Println("Vaults are unsealed!")
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}

func initVault(ip string) *initResponse {
	url := fmt.Sprintf(baseURL, ip, "/sys/init")

	payload := initPayload{
		Shares:    1,
		Threshold: 1,
	}

	bs, err := json.Marshal(payload)
	check(err)

	req, err := http.NewRequest(http.MethodPut, url, bytes.NewReader(bs))
	check(err)

	res, err := http.DefaultClient.Do(req)
	check(err)
	defer res.Body.Close()

	var vres initResponse
	err = json.NewDecoder(res.Body).Decode(&vres)
	check(err)

	return &vres
}

func unsealVaults(ips []string, initRes *initResponse) {
	for _, ip := range ips {
		unsealVault(ip, initRes)
	}
}

func unsealVault(ip string, initRes *initResponse) {
	url := fmt.Sprintf(baseURL, ip, "/sys/unseal")

	for _, key := range initRes.Keys {
		payload := unsealPayload{
			Key: key,
		}

		bs, err := json.Marshal(payload)
		check(err)

		req, err := http.NewRequest(http.MethodPut, url, bytes.NewReader(bs))
		check(err)

		req.Header = map[string][]string{
			"X-Vault-Token": []string{initRes.RootToken},
		}

		res, err := http.DefaultClient.Do(req)
		check(err)
		defer res.Body.Close()

		var vres unsealResponse
		err = json.NewDecoder(res.Body).Decode(&vres)
		check(err)
	}
}
