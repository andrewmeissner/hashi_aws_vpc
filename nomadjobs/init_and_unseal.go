package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"

	consulAPI "github.com/hashicorp/consul/api"
	vaultAPI "github.com/hashicorp/vault/api"
)

var (
	consulClient    *consulAPI.Client
	vaultClient     *vaultAPI.Client
	vaultRootToken  string
	vaultUnsealKeys []string
)

func check(err error) {
	if err != nil {
		panic(err)
	}
}

func init() {
	consulClient = initConsulClient()
}

func initConsulClient() *consulAPI.Client {
	cli, err := consulAPI.NewClient(consulAPI.DefaultConfig())
	check(err)

	return cli
}

func main() {
	vaults, _, err := consulClient.Catalog().Service("vault", "", nil)
	check(err)

	initializeVault(vaults)
	unsealVaults(vaults)
	fmt.Println("Vaults are unsealed!")
}

func initializeVault(vaults []*consulAPI.CatalogService) {
	if vaults != nil && len(vaults) == 0 {
		panic(fmt.Errorf("can't initialize 0 vaults from consul"))
	}

	service := vaults[0]

	vClient, err := vaultAPI.NewClient(&vaultAPI.Config{
		Address: fmt.Sprintf("http://%s:%d", service.Address, service.ServicePort),
	})

	initResp, err := vClient.Sys().Init(&vaultAPI.InitRequest{
		SecretShares:    1,
		SecretThreshold: 1,
	})
	check(err)

	writeCredentials(initResp)

	vaultRootToken = initResp.RootToken
	vaultUnsealKeys = initResp.Keys

	vClient.SetToken(vaultRootToken)

	vaultClient = vClient
}

func unsealVaults(vaults []*consulAPI.CatalogService) {
	for _, vault := range vaults {
		vaultClient.SetAddress(fmt.Sprintf("http://%s:%d", vault.Address, vault.ServicePort))
		for _, key := range vaultUnsealKeys {
			_, err := vaultClient.Sys().Unseal(key)
			check(err)
		}
	}
}

func writeCredentials(resp *vaultAPI.InitResponse) {
	bs, err := json.Marshal(resp)
	check(err)
	check(ioutil.WriteFile("vaultCreds.json", bs, 0644))
}
