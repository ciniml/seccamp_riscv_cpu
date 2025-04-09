use std::{path::PathBuf, env, fs::File, io::Write};

fn main() {
    let out = &PathBuf::from(env::var_os("OUT_DIR").unwrap());
    File::create(out.join("link.ld"))
        .unwrap()
        .write_all(include_bytes!("link.ld"))
        .unwrap();
}