

fn main(){
    let s1 = String::from("hello, ");
    let s2 = String::from("world!");

    // let s3 = &s1 + &s2;
    let s3 = format!("{} {} ", s1, s2);
    println!("{}", s3);

    // let row = vec![
    //     Spread::Int(11),
    //     Spread::Float(3.14),
    //     Spread::Text(String::from("auroot")),
    // ];
    // // let aint = row;
    // println!("{}", &row[Spread::Int]);
    // row.push(Spread::Int(22));


    let mut v = Vec::new();
    // let a = &v[1];

    v.push(6);
    v.push(6);

    for i in &mut v {
        
        println!("{}", i);
    }
    let third: i32 = v[200];

    println!("The third element is {}", third);

    match v.get(100) {
        Some(third) => println!("The third element is {}", third),
        None => println!("There is no third element.")
    }
}
