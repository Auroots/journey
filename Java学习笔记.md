# Java学习笔记

- 第一个Java程序

  ```java
  public class index {
   	public static void main(String[] args){
          System.out.println("Hello world");
      }   
  }
  ```

### 变量和基本数据类型：

```java
1.基本数据类型 primitive type:
    byte	 // 整数类型;
    short	 // 整数类型;
    int		 // 整数类型; 
    long	 // 整数类型;
    float	 // 浮点类型;
    double	 // 浮点类型;
    boolean  // 布尔类型;
    char	 // 字符类型;
2.引用数据类型 reference type:
    class 	   // 类;
    interface  // 接口;
    []    	   // 数组;	
```

- int 类型

```java
int name8 = 123;
int name10 = 012;
int name16 = 0XFF;
能写一个字符
System.out.println("八进制：" + name8);
System.out.println("十进制：" + name10);
System.out.println("十六进制：" + name16);
```

- long 类型

```java
long nameLong = 121313143L; // 结尾需要带 "l" 或 "L"
System.out.println(nameLong);
```

- float 类型

``` java
float nameFloat = 11.3F;	// 单精度浮点型，结尾需要带 "f" 或 "F"
System.out.println(nameFloat);
```

- double 类型

```java
double nameDouble = 11.3;	// 双精度浮点型
System.out.println(nameDouble);
```

- char 类型

```java
char nameChar = 'a';//定义char类型时，通常使用一对''单引号，内部只能写一个字符
System.out.println(nameCha);
```

- String 类型

```java
String nameString = "auroot"; 	// 声明String类型变量时，使用一对""
System.out.println(nameString);
```

- boolean 类型

```java
boolean nameboolean = true; 
boolean nameboolean = false; 
System.out.println(nameString);
```

