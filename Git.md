## GIt 常用命令

| 命令                                   | 作用                                             |
| -------------------------------------- | ------------------------------------------------ |
| git config --global user.name 用户名   | 设置用户名                                       |
| git config --global user.email 邮箱    | 设置用户签名（邮箱）                             |
| git config --global  --list            | 显示用户列表                                     |
| Ssh-keygen -t rsa -C “Git邮箱地址”     | 生成ssh                                          |
| git init                               | 初始化本地库                                     |
| git status                             | 查看本地库状态                                   |
| git add [文件名]                       | 添加到暂存区                                     |
| git commit -m "日志信息" [文件名]      | 提交到本地库                                     |
| git reflog                             | 查看历史记录                                     |
| git reset--hard 版本号                 | 版本穿梭                                         |
| git branch 分支名                      | 创建分支                                         |
| git branch -v                          | 查看分支                                         |
| git checkout 分支名                    | 切换分支                                         |
| git merge 分支名                       | 把指定的分支合并到当前分支上                     |
|                                        |                                                  |
| git remote -v                          | 查看当前所有远程地址别名                         |
| git remote add [别名] [远程地址]       | 起别名                                           |
| git push [别名] [分支]                 | 推送本地分支上的内容到远程仓库                   |
| git clone [远程地址]                   | 将远程仓库的内容克隆到本地                       |
| git pull [远程库地址别名] [远程分支名] | 将远程仓库对与分支最新内容下来后，与本地分支合并 |

## 关于换行符

| 命令                                    | 作用                                             |
| --------------------------------------- | ------------------------------------------------ |
| git config --global core.autocrlf true  | 提交时转换为LF，检出时转换为CRLF（一般设置这个） |
| git config --global core.autocrlf input | 提交时转换为LF，检出时不转换                     |
| git config --global core.autocrlf false | 提交检出均不转换                                 |
|                                         |                                                  |
| git config --global core.safecrlf true  | 拒绝提交包含混合换行符的文件                     |
| git config --global core.safecrlf false | 允许提交包含混合换行符的文件                     |
| git config --global core.safecrlf warn  | 提交包含混合换行符的文件时给出警告               |