# Windows10 Install TensorFlow 2.3

## 配置PiP源

新建文件并编辑：```C:\Users\Auroot\AppData\Roaming\pip\pip.ini```

```[global]
index-url = http://pypi.douban.com/simple/ 
[install]
trusted-host=pypi.douban.com
```

升级pip版本```pip -V```（可选，如果版本大于19.0，可以忽略此步骤）

## 配置MiniConda / Anaconda

可先执行 `conda config --set show_channel_urls yes` 生成该文件之后再修改

C:\Users\Auroot\.condarc

```
channels:
  - defaults
show_channel_urls: true
channel_alias: https://mirrors.tuna.tsinghua.edu.cn/anaconda
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
```

运行 `conda clean -i` 清除索引缓存，保证用的是镜像站提供的索引。

运行 `conda create -n myenv numpy` 测试一下吧。

## CPU

### 搭建开发环境

- Miniconda / Anaconda

- Python 3.5 - 3.8
- [Visual C++](https://support.microsoft.com/zh-cn/help/2977003/the-latest-supported-visual-c-downloads)



### 安装TensorFlow-CPU

CMD运行：

```pip install tensorflow-cpu==2.3.0 -i```

安装其他插件：

```pip install matplotlib notebook```

### 测试

CMD运行：

```python
python
import tensorflow as tf
print(tf.__version__)  
---> 2.3.0
```



## GPU

### 搭建开发环境

- Miniconda / Anaconda

- Python 3.5 - 3.8
- [Visual C++](https://support.microsoft.com/zh-cn/help/2977003/the-latest-supported-visual-c-downloads)

- cuda 10.1
- cudnn 7.6.5 (不小于7.6)
- -Nvidia 418.x 以上 ```nvidia-smi```

### 安装开发环境

```dos
conda install cudatoolkit=10.1
conda install cudnn=7.6.5
pip install tensorflow-gpu==2.3.0 -i 
```

