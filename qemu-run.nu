#!/usr/bin/env nu

def main [
  --bios: string = "third-party/ovmf/RELEASEX64_OVMF.fd",
  --drive: string = "format=raw,file=fat:rw:mnt",
] {
  qemu-system-x86_64 -bios $bios -drive $drive
}
