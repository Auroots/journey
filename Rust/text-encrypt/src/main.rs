use std::env;
use std::fs;
use std::io::{Read, Write};
use base64::{Engine as _, engine::general_purpose};
use colored::Colorize;

fn main() {
    let args: Vec<String> = env::args().collect();
    // 如果没有安装标准执行程序，会返回帮助信息
    if args.len() < 3 {
        usage();
        return;
    }
    // 分别是：输入文件，输出文件，加密=否，解密=否
    let mut input_file = String::new();
    let mut output_file = String::new();
    let mut encrypt = false;
    let mut decrypt = false;

    // 解析命令行参数
    let mut i = 1;
    while i < args.len() {
        match &args[i][..] {
            "-e" | "--encode" => encrypt = true,    // 开启加密
            "-d" | "--decode" => decrypt = true,    // 启用解密
            "-i" | "--input" if i + 1 < args.len() => {
                input_file = args[i + 1].clone();   // 设置输入文件
                i += 1; // 跳过下一个参数
            }
            "-o" | "--output" if i + 1 < args.len() => {
                output_file = args[i + 1].clone();  // 设置输出文件
                i += 1; // 跳过下一个参数
            }
            "-v" | "--version" => {
                println!("Version {}", env!("CARGO_PKG_VERSION"));
                return; // 打印版本信息后结束程序
            }
            "-h" | "--help" => {
                usage();
                return; // 打印帮助信息后结束程序
            }
            _ => eprintln!("{}: no such command: `{}`", "error".red(), &args[i]), // 未知参数
                // Usage: text-encrypt [options] -i <input file>
        }
        i += 1;
    }
    // 请使用-i选项提供一个输入文件
    if input_file.is_empty() {
        println!("Please provide an input file using the -i option.");
        return;
    }

    if encrypt {
        encrypt_file(&input_file, &output_file);
    } else if decrypt {
        decrypt_file(&input_file, &output_file);
    }
}

//  加密文本
fn encrypt_file(input_file: &str, output_file: &str) {
    let mut input_text = String::new();

    match fs::File::open(input_file) {
        Ok(mut file) => {
            file.read_to_string(&mut input_text).unwrap();
        }
        Err(err) => {
            // 打开输入文件时出错
            println!("Error opening input file: {}", err);
            return;
        }
    }
    // 将文本编码为Base64
    let encoded_text = general_purpose::STANDARD.encode(input_text.as_bytes());
    // 将编码后的字符向前移动3位
    let shifted_text = shift_characters(&encoded_text, 3);

    if output_file.is_empty() {
        println!("Encrypted text: {}", shifted_text);
    } else {
        match fs::File::create(output_file) {
            Ok(mut file) => {
                if let Err(err) = file.write_all(shifted_text.as_bytes()) {
                    // 写入输出文件时出错
                    println!("Error writing to output file: {}", err);
                    return;
                }
                // 写入文件的加密文本
                println!("Encrypted text written to file: {}", output_file);
            }
            Err(err) => {
                // 创建输出文件时出错
                println!("Error creating output file: {}", err);
                return;
            }
        }
    }
}

//  解密文件
fn decrypt_file(input_file: &str, output_file: &str) {
    let mut input_text = String::new();

    match fs::File::open(input_file) {
        Ok(mut file) => {
            file.read_to_string(&mut input_text).unwrap();
        }
        Err(err) => {
            // 打开输入文件时出错
            println!("Error opening input file: {}", err);
            return;
        }
    }
    // 将编码后的字符向后移动3位
    let shifted_text = shift_characters(&input_text, -3);
    // 将回位后的字符进行Base64解码
    let decoded_text = match general_purpose::STANDARD.decode(&shifted_text){
        Ok(text) => text,
        Err(err) => {
            // 解码文本时出错
            println!("Error decoding text: {}", err);
            return;
        }
    };
    // 接受一个&[u8]类型的字节切片，并尝试将其解码为UTF-8编码的字符串，并进行包装
    let decoded_text_pack = &String::from_utf8_lossy(&decoded_text);
    // 如果没有使用-o选项，则直接返回解密后的文本，否则将文本输出到文件
    if output_file.is_empty() {
        // Decrypted text 解密后的文本
        println!("{}", decoded_text_pack);
    } else {
        match fs::File::create(output_file) {
            Ok(mut file) => {
                if let Err(err) = file.write_all(decoded_text_pack.as_bytes()) {
                    // 写入输出文件时出错
                    println!("Error writing to output file: {}", err);
                    return;
                }
                // 写入文件的解密文本
                println!("Decrypted text written to file: {}", output_file);
            }
            Err(err) => {
                // 创建输出文件时出错
                println!("Error creating output file: {}", err);
                return;
            }
        }
    }
}

// 移动字符
fn shift_characters(text: &str, shift: i8) -> String {
    let mut shifted_text = String::new();

    for ch in text.chars() {
        if ch.is_ascii_alphabetic() {
            let base_offset = match ch.is_ascii_uppercase() {
                true => b'A',
                false => b'a',
            };
            let shifted_ch = (((ch as u8).wrapping_sub(base_offset) as i32 + shift as i32)
                .rem_euclid(26) as u8)
                .wrapping_add(base_offset) as char;
            shifted_text.push(shifted_ch);
        } else {
            shifted_text.push(ch);
        }
    }

    shifted_text
}

fn usage() {
    let usages = "Text encryption and decryption\n\n\
        Usage: text-encrypt [options] -i <input file>\n\
        Options:\n\
        \t-h, --help : display this help message\n\
        \t-v, --version : display version information\n\
        \t-e, --encode : enable encryption\n\
        \t-d, --decode : enable decryption\n\
        \t-i, --input <file> : set input file\n\
        \t-o, --output <file> : set output file\n";
    println!("{}", usages);
}