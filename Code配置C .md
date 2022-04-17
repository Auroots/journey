# Visual Studio Code 配置C/C++

#### 主要流程：

[Visual Studio Code (vscode) 配置 C / C++ 环境 - 步平凡 - 博客园 (cnblogs.com)](https://www.cnblogs.com/bpf-1024/p/11597000.html)

1. 下载VScode
2. 安装插件
3. 下载MinGW
4. 配置环境变量
5. 使用简单的.cpp文件配置C++环境
6. 运行

#### 插件安装

#### 下载MinGW

下载地址：https://sourceforge.net/projects/mingw-w64/files/

下载的文件：进入网站后不要点击 "Download Lasted Version"，往下滑，找到最新版的 "x86_64-posix-seh"。

安装MinGW：下载后是一个7z的压缩包，解压后移动到你想安装的位置即可。我的安装位置是：*C:\Program Files\mingw64*

#### **配置环境变量**

**验证一下环境变量是否配置成功**

按下 win + R，输入cmd，回车键之后输入g++，再回车，如果提示以下信息[1]，则环境变量配置成功。如果提示以下信息[2]，则环境变量配置失败。

```
[1]：g++: fatal error: no input files
[2]：'g++' 不是内部或外部命令，也不是可运行的程序或批处理文件。
```

#### 编辑 launch.json 配置文件

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "g++.exe build and debug active file",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}\\${fileBasenameNoExtension}.exe",
                "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": true,      //修改此项，让其弹出终端
            "MIMode": "gdb",
            "miDebuggerPath": "C:\\Program Files\\mingw64\\bin\\gdb.exe",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "task g++" //修改此项
        }
    ]
}
```

#### 编辑 tasks.json 文件

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "task g++",
            "type": "shell",
            "command": "C:\\Program Files\\mingw64\\bin\\g++.exe",
            "args": [
                "-g",
                "${file}",
                "-o",
                "${fileDirname}\\${fileBasenameNoExtension}.exe"
            ],
            "options": {
                "cwd": "C:\\Program Files\\mingw64\\bin"
            },
            "group": "build",
            "problemMatcher": "$gcc"
        }
    ]
}
```

#### 新建test.cpp文件测试

```c
#include <stdio.h>
int main()
{
    printf("Hello World\n");
    return 0;
}
```

