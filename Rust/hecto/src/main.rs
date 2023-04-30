// use std::io;
use std::fs;
use std::fs::File;
use std::io::prelude::*;

fn main() -> std::io::Result<()> {
    // 创建空目录
    // fs::create_dir("D:/Users/Auroot/Desktop/库存/")?;
    // 创建级联目录(多级目录)
    // fs::create_dir_all("D:/Users/Auroot/Desktop/库存2/test")?;

    // // 得到文件名，无扩展名
    // let fname = path.file_stem().unwrap();
    let mut f = File::open("D:/Users/Auroot/Desktop/库存.txt")?;
    let mut buf = [0; 12];

    // 读取文件12 byte
    let n = f.read(&mut buf[..])?;

    // read 12
    let n = f.read(&mut buf[..])?;

    println!(&u, n);
    let mut f = File::open("a.txt")?;
    let mut buf = String::new();

    f.read_to_string(&mut buf)?;

    Ok(())
}
