variable "iso_url" {
  type        = string
  description = "A URL to the ISO containing the installation image."
  default     = "https://releases.ubuntu.com/20.04.2/ubuntu-20.04.2-live-server-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "The checksum for the ISO file."
  default     = "md5:aba7e22636c435c5008f5d059ae69a62"
}

variable "cpus" {
  type        = number
  description = "The number of cpus to use for building the VM."
  default     = "1"
}

variable "memory" {
  type        = number
  description = "The amount of memory to use for building the VM."
  default     = "2048"
}

variable "ssh_username" {
  type        = string
  description = "The username to connect to SSH."
  default     = "vagrant"
}

variable "ssh_password" {
  type        = string
  description = "A plaintext password to use to authenticate with SSH."
  default     = "vagrant"
  sensitive   = true
}

variable "headless" {
  type        = bool
  description = "Building VM in quiet mode (without GUI)."
  default     = "true"
}

source "virtualbox-iso" "ubuntu" {
  guest_os_type           = "Ubuntu Desktop 20.04.2"
  iso_url                 = var.iso_url
  iso_checksum            = var.iso_checksum
  boot_command            = [
    "<esc><wait><enter><f6><wait><esc>",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "<enter>"
  ]
  boot_wait               = "5s"
  cpus                    = var.cpus
  memory                  = var.memory
  communicator            = "ssh"
  ssh_timeout             = "1h"
  ssh_username            = var.ssh_username
  ssh_password            = var.ssh_password
  // increase for fix 'Error waiting for SSH:'
  ssh_handshake_attempts  = 50
  headless                = var.headless
  http_directory          = "http"
  shutdown_command        = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  guest_additions_path    = "VBoxGuestAdditions_{{.Version}}.iso"
  virtualbox_version_file = ".vbox_version"
}

build {
  sources = [
    "sources.virtualbox-iso.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ubuntu-desktop"
    ]
  }

  post-processor "vagrant" {
    compression_level = 8
    provider_override = "virtualbox"
    output            = "target/{{.BuildName}}-{{.Provider}}.box"
  }
}
