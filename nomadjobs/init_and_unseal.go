package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"strings"

	consulAPI "github.com/hashicorp/consul/api"
	vaultAPI "github.com/hashicorp/vault/api"
)

var (
	consulClient    *consulAPI.Client
	vaultClient     *vaultAPI.Client
	vaultRootToken  string
	vaultUnsealKeys []string

	adminPolicy = `
path "audit/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "auth/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "cubbyhole/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "secret/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}`
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
	addAdminPolicy(vaults)
	enableUserpassAuth()
	addTestAccount()
}

func initializeVault(vaults []*consulAPI.CatalogService) {
	if vaults != nil && len(vaults) == 0 {
		panic(fmt.Errorf("can't initialize 0 vaults from consul"))
	}

	var config vaultAPI.Config

	if isLocalhost() {
		config = vaultAPI.Config{
			Address: fmt.Sprintf("http://localhost:8200"),
		}
	} else {
		config = vaultAPI.Config{
			Address: fmt.Sprintf("http://%s:%d", vaults[0].Address, vaults[0].ServicePort),
		}
	}

	vClient, err := vaultAPI.NewClient(&config)

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
	fmt.Println("Vaults are initialized!")
}

func unsealVaults(vaults []*consulAPI.CatalogService) {
	if isLocalhost() {
		vaultClient.SetAddress("http://localhost:8200")
		for _, key := range vaultUnsealKeys {
			_, err := vaultClient.Sys().Unseal(key)
			check(err)
		}
	} else {
		for _, vault := range vaults {
			vaultClient.SetAddress(fmt.Sprintf("http://%s:%d", vault.Address, vault.ServicePort))
			for _, key := range vaultUnsealKeys {
				_, err := vaultClient.Sys().Unseal(key)
				check(err)
			}
		}
	}

	if len(vaults) > 0 {
		fmt.Println("Vaults are unsealed!")
	}
}

func addAdminPolicy(vaults []*consulAPI.CatalogService) {
	if isLocalhost() {
		vaultClient.SetAddress("http://localhost:8200")
	} else {
		vaultClient.SetAddress(fmt.Sprintf("http://%s:%d", vaults[0].Address, vaults[0].ServicePort))
	}

	for i := 0; i < 5; i++ {
		if err := vaultClient.Sys().PutPolicy("admin", strings.TrimSpace(adminPolicy)); err != nil {
			continue
		}
		fmt.Println("Admin policy added!")
		return
	}
	fmt.Println("Failed to add admin policy!")
}

func writeCredentials(resp *vaultAPI.InitResponse) {
	bs, err := json.MarshalIndent(resp, "", "    ")
	check(err)
	check(ioutil.WriteFile("vaultCreds.json", bs, 0644))
}

func isLocalhost() bool {
	consulHTTPAddr := os.Getenv("CONSUL_HTTP_ADDR")
	localhost := strings.Contains(consulHTTPAddr, "localhost")
	loopbackAddr := strings.Contains(consulHTTPAddr, "127.0.0.1")
	return localhost || loopbackAddr
}

func enableUserpassAuth() {
	if err := vaultClient.Sys().EnableAuth("userpass", "userpass", "username and password authentication"); err != nil {
		panic(err)
	}
	fmt.Println("Enabled userpass auth backend!")
}

func addTestAccount() {
	if _, err := vaultClient.Logical().Write("auth/userpass/users/admin", map[string]interface{}{"password": "admin", "policies": "admin"}); err != nil {
		panic(err)
	}
	fmt.Println("Added test account to userpass auth backend!")
}
