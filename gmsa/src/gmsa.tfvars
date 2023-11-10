nodes = [
  {
    name     = "gmsa-etcd"
    image    = "linux"
    size     = "Standard_B4als_v2"
    roles    = ["etcd"]
    replicas = 3
  },
  {
    name     = "gmsa-cp"
    image    = "linux"
    size     = "Standard_B4als_v2"
    roles    = ["controlplane"]
    replicas = 1
  },
  {
    name     = "gmsa-worker"
    image    = "linux"
    size     = "Standard_B4als_v2"
    roles    = ["worker"]
    replicas = 2
  },
  {
    name     = "gmsa-windows-server-2019-core"
    image    = "windows-2019-core"
    roles    = ["worker"]
    replicas = 1
  },
  {
    name     = "gmsa-windows-server-2019"
    image    = "windows-2019"
    roles    = ["worker"]
    replicas = 1
  },
  {
    name     = "gmsa-windows-server-2022"
    image    = "windows-2022"
    roles    = ["worker"]
    replicas = 1
  },
  {
    name     = "gmsa-windows-server-core-2022"
    image    = "windows-2022-core"
    roles    = ["worker"]
    replicas = 1
  }
]

apps = {
  cert-manager-crd = {
    path      = "https://github.com/cert-manager/cert-manager/releases/download/v1.12.4/cert-manager.crds.yaml"
    namespace = "cert-manager"
  }

  cert-manager = {
    path         = "https://charts.jetstack.io/charts/cert-manager-v1.12.4.tgz"
    namespace    = "cert-manager"
    values       = {}
    dependencies = ["cert-manager-crd"]
  }

  windows-ad-setup = {
    path      = "charts/windows-ad-setup"
    namespace = "cattle-windows-gmsa-system"
    # Comment this out if you are not using the Active Directory Terraform module
    #
    # This will cause a failure unless you have run the script in the setup_integration
    # output of the Active Directory Terraform module
    #
    # Alternatively, you can manually create the expected `values.json` for an external Active Directory
    values_file  = "dist/active_directory/values.json"
    dependencies = ["rancher-windows-gmsa"]
  }

  windows-gmsa-webserver = {
    path      = "charts/windows-gmsa-webserver"
    namespace = "cattle-wins-system"
    values = {
      gmsa = "gmsa1-ccg"
    }
    dependencies = ["windows-ad-setup", "rancher-gmsa-plugin-installer", "rancher-gmsa-account-provider"]
  }
}
