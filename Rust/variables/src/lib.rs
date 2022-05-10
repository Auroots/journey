// 定义一个trait 名称为：Summary 
pub trait Summary {
    // 定义 summarize 方法
    fn summarize(&self) -> String;
    // fn sumau(&self) -> String;
}

// 定义 NewsArticle 结构体
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}
// impl块只是fn定义的集合
// impl示例1: 为NewsArticle结构体实现Summary trait 集合
impl Summary for NewsArticle {
    // 定义 Summary 中 summarize 方法具体的实现
    fn summarize(&self) -> String {
        format!("{}, by {} ({})",self.headline, self.author, self.location)
    }
}
// impl集合内的函数，都会成为NewsArticle结构体的方法
// impl示例2: 为 NewsArticle 结构体定义方法
impl NewsArticle {
    // 定义方法成员 summarize
    pub fn summarize(&self) -> String {
        format!("{}, by {} ({})",self.headline, self.author, self.location)
    }
}
// 定义 Tweet 结构体
pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}
// 为 Tweet 结构体实现Summary trait
impl Summary for Tweet {
    // 定义 summarize 方法具体的实现
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}