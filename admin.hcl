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
}