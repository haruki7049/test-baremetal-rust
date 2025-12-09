#!/usr/bin/env nu

def main [
  --bios: string = "./third-party/ovmf/RELEASEX64_OVMF.fd",
  --drive: string = "format=raw,file=fat:rw:mnt",
  --do-compile,
  --copy-bootable-file,
] {
  if ($do_compile) {
    print "Running 'cargo build'..."
    cargo build
  }

  if ($copy_bootable_file) {
    print "Copying 'BOOTX64.EFI'..."
    copy_bootx64
    print "Done!!"
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
