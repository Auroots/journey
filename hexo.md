- 本地 创建密钥

```bash
ssh-keygen -t rsa
```

- 服务器 将id_rsa中的内容复制到服务器端~/.ssh/authorized_keys

```bash
mkdir ~/.ssh
vim ~/.ssh/authorized_keys
```

- 本地 测试

```bash
ssh-keygen -R 你要访问的IP地址
ssh -v USER@服务器ip
```





### 报错

1. ERROR Deployer not found: git

```bash
npm install --save hexo-deployer-git
```

