use variables::Summary;
use variables::Tweet;
use variables::NewsArticle;

fn main(){
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    };
    let newsa = NewsArticle {
        headline: String::from("Auins.sh"),
        author: String::from("Auroot"),
        location: String::from("2020"),
        content: String::from("2"),
    };
    println!("1 new tweet: {}", tweet.summarize());
    println!("1 new tweet: {}", newsa.summarize());
}