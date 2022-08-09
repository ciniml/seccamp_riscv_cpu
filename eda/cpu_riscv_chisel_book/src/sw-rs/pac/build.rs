use core::panic;
use std::{path::PathBuf, process::{Command, Stdio}, io::Write};
use svd2rust::{Config, Target};

fn main() {
    let config = {
        let mut config = Config::default();
        config.const_generic = true;
        config.output_dir = PathBuf::from("src");
        config.target = Target::RISCV; 
        config
    };
    let svd = std::fs::read_to_string("cpu_riscv_chisel_book.svd").expect("Failed to read SVD file");
    let generated = svd2rust::generate(&svd, &config).expect("Failed to generate PAC crate");

    let mut cmd = Command::new("rustfmt");
    cmd.stdin(Stdio::piped()).stdout(Stdio::piped());
    let mut rustfmt = cmd.spawn().expect("Failed to launch rustfmt");
    let mut stdin = rustfmt.stdin.take().unwrap();
    let stdin_thread = std::thread::spawn(move || {
        let _ = stdin.write_all(&generated.lib_rs.as_bytes());
    });
    let output = rustfmt.wait_with_output().expect("Failed to wait rustfmt execution");
    stdin_thread.join().expect("Failed to wait rustfmt input thread.");

    let output_string = String::from_utf8(output.stdout).expect("Failed to convert rustfmt output to utf8");
    if !output.status.success() {
        panic!("rustfmt returned error - {}", output.status.code().unwrap());
    }

    if std::fs::read_dir("src").is_err() {
        std::fs::create_dir_all("src").expect("Failed to create pac/src directory.")
    }
    std::fs::write("src/lib.rs", &output_string).expect("Failed to write src/lib.rs");

    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=cpu_riscv_chisel_book.svd");
}
