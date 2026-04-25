#![no_std]
#![no_main]
#![feature(offset_of)]

use core::panic::PanicInfo;
use test_baremetal_rust::graphics::draw_line;
use test_baremetal_rust::graphics::draw_point;
use test_baremetal_rust::graphics::fill_rect;
use test_baremetal_rust::graphics::Bitmap;
use test_baremetal_rust::qemu::exit_qemu;
use test_baremetal_rust::qemu::QemuExitCode;
use test_baremetal_rust::uefi::init_vram;
use test_baremetal_rust::uefi::EfiHandle;
use test_baremetal_rust::uefi::EfiSystemTable;
use test_baremetal_rust::x86::hlt;

#[no_mangle]
fn efi_main(_image_handle: EfiHandle, efi_system_table: &EfiSystemTable) {
    let mut vram = init_vram(efi_system_table).expect("init_vram failed");

    let vw = vram.width();
    let vh = vram.height();
    fill_rect(&mut vram, 0xa0a0a0, 0, 0, vw, vh).expect("fill_rect failed");
    fill_rect(&mut vram, 0xff0000, 32, 32, 32, 32).expect("fill_rect failed");
    fill_rect(&mut vram, 0x00ff00, 64, 64, 64, 64).expect("fill_rect failed");
    fill_rect(&mut vram, 0x0000ff, 128, 128, 128, 128).expect("fill_rect failed");
    for i in 0..256 {
        draw_point(&mut vram, 0x010101 * i as u32, i, i).expect("draw_point failed");
    }

    let grid_size: i64 = 32;
    let rect_size: i64 = grid_size * 8;
    for i in (0..=rect_size).step_by(grid_size as usize) {
        let _ = draw_line(&mut vram, 0xff0000, 0, i, rect_size, i);
        let _ = draw_line(&mut vram, 0xff0000, i, 0, i, rect_size);
    }

    let cx = rect_size / 2;
    let cy = rect_size / 2;
    for i in (0..=rect_size).step_by(grid_size as usize) {
        let _ = draw_line(&mut vram, 0xffff00, cx, cy, 0, i);
        let _ = draw_line(&mut vram, 0xff0000, cx, cy, i, 0);
        let _ = draw_line(&mut vram, 0xffff00, cx, cy, rect_size, i);
        let _ = draw_line(&mut vram, 0xff0000, cx, cy, i, rect_size);
    }

    loop {
        hlt();
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    exit_qemu(QemuExitCode::Fail)
}
