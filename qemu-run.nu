#!/usr/bin/env nu

qemu-system-x86_64 -bios third-party/ovmf/RELEASEX64_OVMF.fd -drive format=raw,file=fat:rw:mnt
