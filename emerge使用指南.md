# Emerge包管理使用指南



### USE flag的颜色

```bash

# 红色：enable
# 蓝色：前面会带一个”-”，表示disable。
# 绿色：enable但是还没有加进去的use flag
# 黄色：上一个版本没有，这一个版本新加入的use flag
# 括号()：在你的平台上禁用的use flag
```



### Use 标志

```bash
REQUIRED_USE="foo? ( bar )"    　　　　	# 如果 foo 被设定,则必须设定bar
REQUIRED_USE="foo? ( !bar )"    　　　　# 如果 foo 被设定,则必须不设定bar
REQUIRED_USE="foo? ( || ( bar baz ) )" # 如果 foo被设定,则必须设定 bar或baz
REQUIRED_USE="^^ ( foo bar baz )"    　# foo bar或baz中必须有一个被设定
REQUIRED_USE="|| ( foo bar baz )"    　# foo bar或baz中至少有一个被设定。
REQUIRED_USE="?? ( foo bar baz )"    　# foo bar或baz中必须同时被设定多个USE

B (blocks)       # 左边列出来的软件因为冲突原因将阻碍右边列出来的软件的安装
N (new)          # 对于您的系统来说这是一个新软件, 且为第一次安装
NS(new slot)     # 安装另外一个版本（slot）
R (replace)      # 不是新软件, 不过会被重新 emerge (reemerged)
r                # 更新小版本（小幅升级）
F (fetch)        # 该软件要求您先把源码手工地下载回来 
				 # 例如：因为许可 (licencing issues) 的缘故
f                # 源码已经下载到系统
U (update)       # 软件包已安装, 不过将被升级
UD (downgrade)   # 软件包已安装, 不过将被降级
#                # 被package.mask屏蔽
*                # 缺少关键字 (missing keyword) 
~                # 不稳定关键字 (unstable keyword) 

ipv6*            # 上一次是被关闭的                
-qt%             # 上一次是被开启的
```



### emerge包管理使用方法

```bash
emerge
    --update 		# 更新
    --deep 			# 连同依赖一起更新
    --with-bdeps=y  # 编译依赖更新
    --newuse 		# 按变化后的use更新
    -u(--update)	# 更新指定软件
    -u system		# 更新系统软件
    -u world　　　   # 更新自己安装的软件（不含依赖的依赖）
    -e world		# 重新编译所有软件包
    --nodeps		# 不理会依赖（安装可能会失败）
    --onlydeps		# 只安装依赖不安装软件
    --getbinpkg		# 下载并安装预编译包
    -C 				# 卸载软件
        !mtime: 	# 目标文件在安装后被您或被一些工具修改过
        !empty: 	# 目标目录不为空
        cftpro: 	# 目标文件在受保护的目录内, 不去碰它以策安全
    -p		# 模拟安装（假设安装，适合不熟悉软件的使用）
    -a 		# 询问
    -s 		# 查询包名
    -f		# 下载源码以及依赖，但是不编译
    -fp		# 查看软件以及依赖的下载地址
    -k		# 安装本地预编译包，否则下载源码，Gentoo不提供预编译包，Portage是应社区加入该功能
    -K		# 安装预编译包（不考虑版本）
    -G		# 下载并安装预编译包（重新下载安装，不使用本地的）
    -v		# 查看详细信息
    -V		# 查看emerge命令的版本，单独使用
    @world  # 更新整个系统
    
emerge -uDN --with-bdeps=y @world
emerge "<vim-8.1"	# 安装小于指定版本软件
emerge-webrsync		#　更新portage
emerge --ask　　　　　# a询问, s查询包名, k使用本地预编译包，否则下载源码
emerge --ask --verbose --update --deep --with-bdeps=y --newuse @world # 更新系统
emerge --depclean --pretend  # 预清理，不是真实清理 (更新完成后推荐)
emerge -avt --depclean 		 # 删除不需要的包 (更新完成后推荐)
emerge --ask --verbose --emptytree --with-bdeps=y @world 
```











