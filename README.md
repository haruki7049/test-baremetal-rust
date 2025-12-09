# test-baremetal-with-stable-rustc

```sh
nix-shell
./qemu-run.nu

# Or run QEMU manually
nix-shell
qemu-system-x86_64 -bios ./third-party/ovmf/RELEASEX64_OVMF.fd -drive format=raw,file=fat:rw:mnt
```
