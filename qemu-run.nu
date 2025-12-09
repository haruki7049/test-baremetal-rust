#!/usr/bin/env nu

def main [
  --bios: string = "./third-party/ovmf/RELEASEX64_OVMF.fd",
  --drive: string = "format=raw,file=fat:rw:mnt",
  --copy-bootable-file = true,
] {
  if ($copy_bootable_file) {
    copy_bootx64
  }

  qemu-system-x86_64 -bios $bios -drive $drive
}

def copy_bootx64 [
  path: string = "./target/x86_64-unknown-uefi/debug/test-baremetal-rust.efi",
  dest: string = "./mnt/EFI/BOOT/BOOTX64.EFI",
] {
  mkdir ($dest | path dirname)

  cp $path $dest
}
