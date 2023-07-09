// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2023.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

use core::fmt;
use std::{str::FromStr, fs, path::PathBuf, ffi::OsStr};

use bitvec::field::BitField;
use bytes::BytesMut;
use clap::Parser;
use env_logger::Env;
use tokio_serial::SerialPortBuilderExt;
use tokio_util::codec::Decoder;
use futures::stream::StreamExt;

#[derive(Debug, Clone)]
struct Signal {
    name: String,
    width: usize,
}

impl FromStr for Signal {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut parts = s.split(':');
        let name = parts.next().ok_or("name must be specified.")?.to_string();
        let width = parts.next().ok_or("width must be specified.")?
            .parse().map_err(|e| format!("width must be a number: {}", e))?;
        if width == 0 {
            return Err("width must be greater than 0.".to_string());
        }
        Ok(Self { name, width })
    }
}

#[derive(Parser, Debug)]
struct Cli {
    #[arg(long)]
    port: String,
    #[arg(long = "signal", required = true, num_args = 1.., value_parser = clap::value_parser!(Signal))]
    signals: Vec<Signal>,
    #[arg(long)]
    bin: Option<String>,
    #[arg(long)]
    csv: Option<String>,
    #[arg(long = "with-index", default_value = "false")]
    with_index: bool,
    #[arg(long, value_parser = clap::value_parser!(u64).range(1..))]
    count: Option<u64>,
}

struct FrameCodec;

impl Decoder for FrameCodec {
    type Item = Vec<u8>;
    type Error = anyhow::Error;

    fn decode(&mut self, src: &mut BytesMut) -> Result<Option<Self::Item>, Self::Error> {
        let sof = src.iter().position(|b| *b == 0x80);
        if let Some(sof_index) = sof {
            let eof = src.iter().skip(sof_index).position(|b| *b == 0x81);
            if let Some(eof_index_from_sof) = eof {
                let mut frame = src.split_to(sof_index + eof_index_from_sof + 1);
                let _ = frame.split_to(sof_index);
                assert_eq!(frame[0], 0x80);
                assert_eq!(frame[frame.len() - 1], 0x81);
                let body = &frame[1..frame.len() - 1];
                return Ok(Some(body.to_vec()));
            }
        }
        Ok(None)
    }
}

#[derive(Debug)]
struct SignalBits<'a> {
    bits: &'a bitvec::slice::BitSlice<u8, bitvec::order::Lsb0>,
}
impl fmt::LowerHex for SignalBits<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let number_of_nibbles = (self.bits.len() + 3) / 4;
        for nibble_index in (0..number_of_nibbles).rev() {
            let upper_bit = usize::min((nibble_index + 1) * 4 - 1, self.bits.len() - 1);
            let lower_bit = nibble_index * 4;
            let nibble: u8 = self.bits[lower_bit..=upper_bit].load();
            write!(f, "{:x}", nibble)?;
        } 
        Ok(())
    }
}

/**
 * Signal buffer that can read a bit / a nibble (4bits) from the signal frame payload.
 */
#[derive(Debug)]
struct SignalBuffer<'a> {
    bits: &'a [u8],
    offset: usize,          // Offset in bits from the beginning of the singal buffer to the first bit of the signal.
    number_of_bits: usize,  // Number of bits of the signal.
}

impl<'a> SignalBuffer<'a> {
    pub fn new(bits: &'a [u8], offset: usize, number_of_bits: usize) -> Self {
        Self { bits, offset, number_of_bits }
    }
    /**
     * Get a bit from the signal buffer.
     */
    #[allow(dead_code)]
    pub fn get(&self, index: usize) -> bool {
        let byte_index = (index + self.offset) / 7;
        let bit_index = (index + self.offset) % 7;
        self.bits[byte_index] & (1 << bit_index) != 0
    }
    /**
     * Get a nibble (4bits) from the signal buffer.
     * If the length of signal buffer is too short to get a nibble, the upper bits are filled with 0.
     * If the length of signal buffer is too short to get a first bit, this function will panic.
     */
    pub fn get_nibble(&self, mut lower_bit: usize) -> u8 {
        lower_bit += self.offset;
        let upper_bit = (self.number_of_bits + self.offset - 1).min(lower_bit + 3);
        let bit_count = upper_bit - lower_bit + 1;
        let bit_mask = (1u8 << bit_count) - 1;
        let first_byte_index = lower_bit / 7;
        let second_byte_index = upper_bit / 7;
        if first_byte_index == second_byte_index {
            let bit_offset = lower_bit % 7;
            (self.bits[first_byte_index] >> bit_offset) & bit_mask
        } else {
            let first_byte = self.bits[first_byte_index];
            let second_byte = self.bits[second_byte_index];
            let first_bit_offset = lower_bit % 7;
            let second_bit_offset = 7 - first_bit_offset;
            ((first_byte >> first_bit_offset) | (second_byte << second_bit_offset)) & bit_mask
        }
    }
}

/**
 * Implementation of fmt::LowerHex for SignalBuffer to be formatteed with {:x} format.
 */
impl fmt::LowerHex for SignalBuffer<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        // Read nibbles from MSb to LSB and print it as hex string.
        let number_of_nibbles = (self.number_of_bits + 3) / 4;
        for nibble_index in (0..number_of_nibbles).rev() {
            let nibble = self.get_nibble(nibble_index * 4);
            write!(f, "{:x}", nibble)?;
        } 
        Ok(())
    }
}

/**
 * Make output path from base output file name and trigger counter.
 */
fn make_output_path(output: &str, count: u64) -> PathBuf {
    let mut path = PathBuf::from(output);
    let extension = path.extension().unwrap_or(OsStr::new(""));
    path.set_extension(format!("{}.{}", count, extension.to_str().unwrap()));
    path
}

fn write_signals_as_csv(signals: &[Signal], body: &[u8], csv_path: &PathBuf, with_index: bool) -> anyhow::Result<()> {
    let csv_file = fs::File::create(csv_path)?;
    let mut csv_writer = csv::Writer::from_writer(csv_file);
    
    let mut head = &body[0..];
    let total_bits = signals.iter().map(|s| s.width).sum::<usize>();
    let total_bytes = (total_bits + 6) / 7; // Payload bytes contain 7 bits/byte

    // Write header
    if with_index {
        csv_writer.write_field("index")?;
    }
    for signal in signals {
        csv_writer.write_field(&signal.name)?;
    }
    csv_writer.write_record(None::<&[u8]>)?;

    let mut index = 0;
    while head.len() >= total_bytes {
        let mut bit_offset = 0;
        if with_index {
            csv_writer.write_field(format!("{}", index))?;
        }
        for signal in signals {
            let signal_buffer = SignalBuffer::new(&head[0..total_bytes], bit_offset, signal.width);
            csv_writer.write_field(format!("{signal_buffer:x}"))?;
            bit_offset += signal.width;
        }
        csv_writer.write_record(None::<&[u8]>)?;
        
        head = &head[total_bytes..];
        index += 1;
    }
    csv_writer.flush()?;
    Ok(())
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    env_logger::Builder::from_env(Env::default().default_filter_or("info")).init();
    let args = Cli::parse();
    log::debug!("args: {:?}", args);
    if args.bin.is_none() && args.csv.is_none() {
        log::error!("no output specified. use --bin or --csv to specify output.");
        return Ok(());
    }

    let port = tokio_serial::new(args.port, 115200).open_native_async()?;
    let mut reader = FrameCodec.framed(port);
    let mut count = 0;
    log::info!("waiting trigger...");
    while let Some(body) = reader.next().await {
        let body = body.expect("failed to read from serial port");
        log::info!("triggered {}/{}", count + 1, args.count.unwrap_or(0));
        if let Some(csv) = &args.csv {
            let csv_path = make_output_path(csv, count);
            if let Err(err) = write_signals_as_csv(&args.signals, &body, &csv_path, args.with_index) {
                log::error!("failed to write csv to {}: {}", csv_path.display(), err);
            }
        }
        if let Some(bin) = &args.bin {
            let output_path = make_output_path(bin, count);
            if let Err(err) = fs::write(&output_path, body) {
                log::error!("failed to write binary to {}: {}", output_path.display(), err);
            }
        }
        count += 1;
        // Check remaining count.
        if let Some(max_count) = args.count {
            if count >= max_count {
                break;
            }
        }
    }
    Ok(())
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn signal_buffer_1bit() {
        let bits = [0b00000000];
        let signal_buffer = SignalBuffer::new(&bits, 0, 1);
        assert_eq!(signal_buffer.get(0), false);
        
        let bits = [0b00000001];
        let signal_buffer = SignalBuffer::new(&bits, 0, 1);
        assert_eq!(signal_buffer.get(0), true);
        assert_eq!(signal_buffer.get_nibble(0), 0b0001);
    }

    #[test]
    fn signal_buffer_7bit() {
        let bits = [0b00000000];
        let signal_buffer = SignalBuffer::new(&bits, 0, 7);
        assert_eq!(signal_buffer.get(0), false);
        assert_eq!(signal_buffer.get_nibble(0), 0);
        assert_eq!(signal_buffer.get_nibble(4), 0);
        
        let bits = [0b11111111];
        let signal_buffer = SignalBuffer::new(&bits, 0, 7);
        assert_eq!(signal_buffer.get(0), true);
        assert_eq!(signal_buffer.get(6), true);
        assert_eq!(signal_buffer.get_nibble(0), 0b1111);
        assert_eq!(signal_buffer.get_nibble(1), 0b1111);
        assert_eq!(signal_buffer.get_nibble(2), 0b1111);
        assert_eq!(signal_buffer.get_nibble(3), 0b1111);
        assert_eq!(signal_buffer.get_nibble(4), 0b0111);
    }
    #[test]
    fn signal_buffer_8bit() {
        let bits = [0b00000000, 0b00000000];
        let signal_buffer = SignalBuffer::new(&bits, 0, 8);
        assert_eq!(signal_buffer.get(0), false);
        assert_eq!(signal_buffer.get_nibble(0), 0);
        assert_eq!(signal_buffer.get_nibble(4), 0);
        
        let bits = [0b01111111, 0b00000001];
        let signal_buffer = SignalBuffer::new(&bits, 0, 8);
        assert_eq!(signal_buffer.get(0), true);
        assert_eq!(signal_buffer.get(6), true);
        assert_eq!(signal_buffer.get(7), true);
        assert_eq!(signal_buffer.get_nibble(0), 0b1111);
        assert_eq!(signal_buffer.get_nibble(1), 0b1111);
        assert_eq!(signal_buffer.get_nibble(2), 0b1111);
        assert_eq!(signal_buffer.get_nibble(3), 0b1111);
        assert_eq!(signal_buffer.get_nibble(4), 0b1111);
        assert_eq!(signal_buffer.get_nibble(5), 0b0111);
    }
}