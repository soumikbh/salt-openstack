pkgrepo:
  pre_repo_additions:
    - "software-properties-common"
    - "ubuntu-cloud-keyring"
  repos:
    Juno-Cloud:
      name: "http://ppa.launchpad.net/ubuntu-cloud-archive/juno-staging/ubuntu trusty main"
      file: "/etc/apt/sources.list.d/cloudarchive-juno.list"
