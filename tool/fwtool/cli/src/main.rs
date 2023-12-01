// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2023.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

use core::fmt;
use std::cell::RefCell;
use std::pin::Pin;
use std::{str::FromStr, fs, path::PathBuf, ffi::OsStr};

use clap::{Parser, Subcommand};
use env_logger::Env;
use tokio::io::{AsyncRead, AsyncWrite};
use tokio_serial::{SerialPortBuilderExt, SerialStream};
use fwtool::client::Client;
use fwtool::frame::Frame;


#[derive(Parser, Debug)]
#[clap(name = "fwtool", author, about, version)]
struct Cli {
    #[clap(subcommand)]
    command: Commands,
}

#[derive(Debug, Subcommand)]
enum Commands {
    Query(QueryCommand),
}

#[derive(Debug, clap::Args)]
struct QueryCommand {
    #[arg(long)]
    port: String,
    #[arg(long, default_value = "115200")]
    baud_rate: u32,
}

struct SerialStreamReader<'a> {
    serial: &'a RefCell<SerialStream>,
}

impl<'a> SerialStreamReader<'a> {
    pub fn new(serial: &'a RefCell<SerialStream>) -> Self {
        Self {
            serial,
        }
    }
}
impl<'a> AsyncRead for SerialStreamReader<'a> {
    fn poll_read(
        self: std::pin::Pin<&mut Self>,
        cx: &mut std::task::Context<'_>,
        buf: &mut tokio::io::ReadBuf<'_>,
    ) -> std::task::Poll<std::io::Result<()>> {
        let mut serial = self.serial.borrow_mut();
        let pinned = Pin::new(&mut *serial);
        pinned.poll_read(cx, buf)
    }
}

struct SerialStreamWriter<'a> {
    serial: &'a RefCell<SerialStream>,
}
impl<'a> SerialStreamWriter<'a> {
    pub fn new(serial: &'a RefCell<SerialStream>) -> Self {
        Self {
            serial,
        }
    }
}
impl<'a> AsyncWrite for SerialStreamWriter<'a> {
    fn poll_write(
        self: Pin<&mut Self>,
        cx: &mut std::task::Context<'_>,
        buf: &[u8],
    ) -> std::task::Poll<Result<usize, std::io::Error>> {
        let mut serial = self.serial.borrow_mut();
        let pinned = Pin::new(&mut *serial);
        pinned.poll_write(cx, buf)
    }

    fn poll_flush(self: Pin<&mut Self>, cx: &mut std::task::Context<'_>) -> std::task::Poll<Result<(), std::io::Error>> {
        let mut serial = self.serial.borrow_mut();
        let pinned = Pin::new(&mut *serial);
        pinned.poll_flush(cx)
    }

    fn poll_shutdown(self: Pin<&mut Self>, cx: &mut std::task::Context<'_>) -> std::task::Poll<Result<(), std::io::Error>> {
        let mut serial = self.serial.borrow_mut();
        let pinned = Pin::new(&mut *serial);
        pinned.poll_shutdown(cx)
    }
}

async fn query_version(command: QueryCommand) -> anyhow::Result<()> {
    log::debug!("query version");

    let serial = RefCell::new(tokio_serial::new(command.port, command.baud_rate).open_native_async()?);
    let mut reader = SerialStreamReader::new(&serial);
    let mut writer = SerialStreamWriter::new(&serial);

    let mut client = Client::new();
    client.query_version(&mut reader, &mut writer).await?;

    Ok(())
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    env_logger::Builder::from_env(Env::default().default_filter_or("info")).init();
    let args = Cli::parse();
    log::debug!("args: {:?}", args);
    
    match args.command {
        Commands::Query(command) => query_version(command).await?,
    }

    Ok(())
}

#[cfg(test)]
mod test {
    
}