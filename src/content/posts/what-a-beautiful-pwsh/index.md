---
title: PowerShell配置文件：美化PowerShell、优化PROFILE启动速度
pinned: false
description: 让PowerShell获得更好看的界面效果，更称心如意的快捷键
tags: [pwsh, 配置, 美化]
category: 技术
author: 雪纷飞
draft: false
published: 2026-03-07
image: "./pwsh-logo.png"
---

# 预览

先来展示效果吧！

![最终的效果][效果]

# 特性

- **启动速度快**：从加载配置文件开始，到成功展示Prompt，总用时300ms。
- **简洁但美观大方**：Prompt并不花里胡哨——正相反，只展示有用的信息（用户与主机名、虚拟环境、当前目录、Git情况、退出码）。
- **追加换行**：命令执行完毕后自动追加换行。
- **无污染命名空间**：脚本的所有变量都不会污染到全局名称空间。

# 开始吧

这个配置文件基本是分块的。

## 开头

```ps1
if (-not $Host.UI -or $Host.Name -notmatch 'ConsoleHost') { return }
```

PowerShell的配置文件并不一定只会在交互式终端里加载。有些宿主环境并没有完整的UI，有些也根本不是我们平时敲命令的控制台。只有真的运行在交互式控制台里，后续逻辑才继续执行。

## 前置依赖

```ps1
winget install gsudo
cargo install posh-fzf
Install-Module -Name Get-ChildItemColor
```

它们分别负责三件事：

- `gsudo`：给Windows提供一个接近Linux `sudo`的提权体验。[官方网页][gsudo]。
- `posh-fzf`：使用`fzf`进行历史命令的模糊查找。
- `Get-ChildItemColor`：给`ls` / `ll`这样的目录列表加上颜色。
> PowerShell自带的`Get-ChildItem`有点难看啊，特别是在文件多的时候，即使是`gci | fw`也很难看。

如果你不需要其中某一项，可以把对应的功能块删掉。

## 防止污染命名空间

将主体内容放在匿名作用域里，以防止污染命名空间：

```ps1
& {

$data = @{
    LeafDir = "";
    HasGit = $null;
    IsFirstPrompt = $true;
    ManualTitle = $null;
    LastWindowTitle = $null;
    LastGitProbePath = $null;
    LastGitDir = $null;
}

# ……

}
```

这样做，我们确保了临时变量不会泄漏到全局作用域。

:::NOTE[Note：为什么使用一个`HashTable`来储存变量]
PowerShell的`CommandBlock`会捕获外部变量。对于值类型，会直接捕获值，我们就无法在内部作用域里修改变量的值了。因此这里选择引用类型。
:::

## 快捷键设置

这里按照个人的爱好更改就行了。下面是笔者的配置：

```ps1
Set-PSReadLineOption -EditMode Emacs
#Set-PSReadLineKeyHandler -Key 'Ctrl+u' -Function BackwardKillLine # 目前的PSReadLine(2.4.5)有BUG，无法正常运行这个Function
Set-PSReadLineKeyHandler -Key 'Ctrl+Enter' -Function AddLine
Set-PSReadLineKeyHandler -Key 'Ctrl+v' -Function Paste
Set-PSReadLineKeyHandler -Key 'Shift+Insert' -Function Paste
Set-PSReadLineKeyHandler -Key "Ctrl+Delete" -Function KillWord
Set-PSReadLineKeyHandler -Key "Ctrl+Backspace" -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+y' -Function Redo
```

笔者个人更喜欢`Emacs`风格的命令行编辑模式，因为它在类Unix环境和许多REPL里都很常见，迁移成本低。除此之外，还补了几组个人喜好的：

- `Ctrl+Enter`：在当前命令后换行。~主要是Alacritty无法发送`Shift+Enter`~
- `Ctrl+v` / `Shift+Insert`：粘贴，没什么好说的。
- `Ctrl+Delete` / `Ctrl+Backspace`：按单词删除。虽然但是，为什么不使用`Alt+d` / `Alt+Backspace`呢？
- `Ctrl+x, Ctrl+y`：重做。

自定义快捷键的时候，**确保你的设定在`Set-PSReadLineOption`之后**，因为`Set-PSReadLineOption`会清空目前已经设定的快捷键。

## 别名展开

有时笔者会先写出一串简写命令，确认无误之后，再把它们展开成完整命令，方便阅读和二次修改。为此绑定了一个`Alt+e`：

```ps1
Set-PSReadLineKeyHandler -Key 'Alt+e' -BriefDescription "ExpandAliases" -LongDescription "展开当前命令行中的所有别名" -ScriptBlock {
    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
    $cmdFlag = [System.Management.Automation.Language.TokenFlags]::CommandName
    $aliasType = [System.Management.Automation.CommandTypes]::Alias
    $startAdjustment = 0
    $newCursor = $cursor
    foreach ($token in $tokens) {
        if ($token.TokenFlags -band $cmdFlag) {
            $aliasInfos = @($ExecutionContext.InvokeCommand.GetCommands($token.Text, $aliasType, $false))
            if ($aliasInfos.Count -gt 0) {
                $resolvedCommand = $aliasInfos[0].Definition
                if (![string]::IsNullOrEmpty($resolvedCommand)) {
                    $origStart = $token.Extent.StartOffset
                    $origEnd = $token.Extent.EndOffset
                    $origLength = $origEnd - $origStart
                    $start = $origStart + $startAdjustment
                    $diff = $resolvedCommand.Length - $origLength
                    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($start, $origLength, $resolvedCommand)
                    $startAdjustment += $diff
                    if ($cursor -ge $origEnd) {
                        $newCursor += $diff
                    } elseif ($cursor -gt $origStart -and $cursor -lt $origEnd) {
                        $newCursor = $origEnd + $startAdjustment
                    }
                }
            }
        }
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($newCursor)
}
```

借助`PSReadLine`提供的抽象语法树来分析，效率不错。

*例：* 

```ps1
gci src | ? Name -like '*Config*'
```

按下`Alt+e`之后，就可以展开成`Get-ChildItem src | Where-Object Name -like '*Config*'`。

## 自定义标题

模仿`tmux`，让窗口标题显示当前shell和所在目录。

```ps1
$writeTitle = {
    param([Parameter(Mandatory)][string] $Title)
    if ($data.LastWindowTitle -eq $Title) { return }
    try { $Host.UI.RawUI.WindowTitle = $Title } catch { $null = $_ }
    try { [Console]::Write("`e]0;$Title`a") } catch { $null = $_ }
    $data.LastWindowTitle = $Title
}.GetNewClosure()

Set-Item -Path Function:\global:Set-Title -Value {
    param([Parameter(Mandatory)][string] $Title)
    $data.ManualTitle = $Title
}.GetNewClosure()

Set-Item -Path Function:\global:Clear-Title -Value {
    $data.ManualTitle = $null
}.GetNewClosure()
```

- 统一封装一个内部的标题写入函数。
- 如果标题没有变化，就直接跳过。
- 暴露两个全局函数：`Set-Title` 和`Clear-Title`，用于手动接管标题。

## Prompt

### 先准备颜色和基础信息

```ps1
$env:VIRTUAL_ENV_DISABLE_PROMPT = $true

$cReset   = "`e[0m"
$cGreen   = "`e[32m"
$cCyan    = "`e[36m"
$cYellow  = "`e[33m"
$cBlue    = "`e[34m"
$cRed     = "`e[31m"
$cMagenta = "`e[35m"
$fBold    = "`e[1m"
$fNormal  = "`e[22m"
```

禁用虚拟环境自带的Prompt修改逻辑，否则它会和我们自己的Prompt叠加。

使用ANSI义序列，方便一些。

### 判断当前是不是管理员

```ps1
$isAdmin = $false
$version = $PSVersionTable.PSVersion
if ($version.Major -eq 7 -and $version.Minor -ge 4) {
    $isAdmin = [System.Environment]::IsPrivilegedProcess
} else {
    if ($IsWindows) {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $isAdmin = [Security.Principal.WindowsPrincipal]::new($identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } elseif ($IsLinux -or $IsMacOS) {
        $isAdmin = (id -u) -eq 0
    }
}
```

管理员用红色用户名，Prompt末尾用 `#`；普通用户则用蓝色和 `>`。

:::NOTE
自PowerShell 7.4起，采用.NET 8，我们就可以用`[System.Environment]::IsPrivilegedProcess`来迅速判断是否为管理员。

如果版本更低，笔者首先建议你更新一下PowerShell。

另外，fallback的判断方式对于Windows来说效率是足够的，但是linux的话，由于会启动一个子进程`id`，就会卡顿一点点。
:::

### Git探测

如果每次渲染Prompt都跑一遍 `git status`，那Prompt或许卡顿到爆炸。

这里笔者模仿[posh-git]的逻辑，先迅速探测是否可能在git仓库内。

```ps1
$getGitDirFast = {
    $pwdInfo = $PWD
    if ($pwdInfo.Provider.Name -ne 'FileSystem') {
        return $null
    }
    $currentDir = $pwdInfo.ProviderPath
    while (-not [string]::IsNullOrEmpty($currentDir)) {
        $dotGit = [System.IO.Path]::Combine($currentDir, '.git')
        if ([System.IO.Directory]::Exists($dotGit) -or [System.IO.File]::Exists($dotGit)) {
            return $dotGit
        }
        $currentDir = [System.IO.Path]::GetDirectoryName($currentDir)
    }
    return $null
}.GetNewClosure()
```

:::NOTE
我们会尽可能使用.NET原生的库和函数，避免使用PowerShell的cmdlet和管道——尽管他们很方便，但毕竟会慢一些。
:::

先沿着当前目录向上找`.git`，找到了再调用`git status`；根本不在仓库里，就完全跳过Git相关开销。

此外，顺手缓存了最近一次探测路径和结果。只要当前目录没变，就不重复扫描。

### 拼装信息

`prompt`这个函数做的事并不少：

1. 在最开头保存`$?`和`$LASTEXITCODE`。
2. 读取虚拟环境名称。
3. 格式化当前目录，把家目录显示成`~`。
4. 如果在Git仓库里，显示额外的信息。
5. 根据上一条命令成功或失败，显示绿色`(0)`或红色退出码。
6. 判断是否在Prompt前额外补一个换行。
7. 刷新窗口标题。
8. 恢复`$?`和`$LASTEXITCODE`。

但除了“4. 如果在Git仓库里，显示额外的信息。”之外，其他步骤都完全不耗时。可以接受。

对应代码：

```ps1
Set-Item -Path Function:\prompt -Value {
    # 必须在最前面捕获
    $lastSuccess = $?
    $lastExit = $LASTEXITCODE

    if ($data.HasGit -eq $null) {
        $data.HasGit = [bool](Get-Command git -CommandType Application -ErrorAction Ignore)
    }

    # 虚拟环境
    $pVenv = ""
    if ($env:VIRTUAL_ENV) {
        $venvName = [System.IO.Path]::GetFileName($env:VIRTUAL_ENV)
        $pVenv = " ${cMagenta}(${venvName})${cReset}"
    }

    # 当前工作目录
    $cwd = $PWD.Path
    if ($cwd.StartsWith($HOME)) {
        $cwd = "~" + $cwd.Substring($HOME.Length)
    }
    $pCwd = " ${cReset}${fBold}${cwd}${cReset}${fNormal}"

    # Git分支信息
    $pGit = ""
    if ($data.HasGit) {
        $probePath = $PWD.ProviderPath
        if ($data.LastGitProbePath -eq $probePath) {
            $gitDir = $data.LastGitDir
        }
        else {
            $gitDir = & $getGitDirFast
            $data.LastGitProbePath = $probePath
            $data.LastGitDir = $gitDir
        }
        
        if ($gitDir) {
            $realGitDir = $gitDir
            if ([System.IO.File]::Exists($gitDir)) {
                try {
                    $gitdirContent = [System.IO.File]::ReadAllText($gitDir)
                    if ($gitdirContent.StartsWith("gitdir: ")) {
                        $targetDir = $gitdirContent.Substring(8).Trim()
                        if ([System.IO.Path]::IsPathRooted($targetDir)) {
                            $realGitDir = $targetDir
                        } else {
                            $gitParent = [System.IO.Path]::GetDirectoryName($gitDir)
                            $realGitDir = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($gitParent, $targetDir))
                        }
                    }
                } catch { }
            }

            $branch = 'unknown'
            $headFile = [System.IO.Path]::Combine($realGitDir, 'HEAD')
            if ([System.IO.File]::Exists($headFile)) {
                try {
                    $headContent = [System.IO.File]::ReadAllText($headFile).Trim()
                    if ($headContent.StartsWith('ref: refs/heads/')) {
                        $branch = $headContent.Substring(16)
                    } elseif ($headContent -match '^[0-9a-fA-F]{40}$') {
                        $branch = $headContent.Substring(0, 7)
                    } else {
                        $branch = 'detached'
                    }
                } catch { }
            }

            $dirtyMarker = ""
            $disableDirty = [bool](-not [string]::IsNullOrWhiteSpace($env:DISABLE_UNTRACKED_FILES_DIRTY)) -and 
                            ($env:DISABLE_UNTRACKED_FILES_DIRTY -ne 'false') -and 
                            ($env:DISABLE_UNTRACKED_FILES_DIRTY -ne '0')
            if (-not $disableDirty) {
                $statusOutput = git --no-optional-locks status --porcelain -uno 2>$null
                if ($LASTEXITCODE -eq 0 -and $statusOutput) {
                    $dirtyMarker = "${cRed}*${cYellow}"
                }
            }
            $pGit = " ${cYellow}git:(${branch}${dirtyMarker})${cReset}"
        }
    }

    # 退出码
    $pExitCode = ""
    if ($lastSuccess) {
        $pExitCode = "${cGreen}(0)${cReset} "
    } else {
        $displayCode = if ($lastExit) { $lastExit } else { "X" }
        $pExitCode = "${cRed}($displayCode)${cReset} "
    }

    # 刚刚打开终端不换行、刚刚clear了不换行
    $pos = $Host.UI.RawUI.CursorPosition
    $justCleared = ($pos.X -eq 0 -and $pos.Y -eq 0)
    $newLine = if ($data.IsFirstPrompt -or $justCleared) { "" } else { "`n" }
    $data.IsFirstPrompt = $false

    # 标题
    if ($null -eq $data.ManualTitle) {
        $data.LeafDir = if ($cwd -eq "~") { "~" } else { [System.IO.Path]::GetFileName($cwd) }
        & $writeTitle "${titleAdminWarn}${shell} $($data.LeafDir)"
    }
    else {
        & $writeTitle $data.ManualTitle
    }

    # 恢复被篡改的关键变量
    $global:LASTEXITCODE = $lastExit
    if ($lastSuccess) { $null = 1 } else { Get-Variable ___Magic_Var_To_Trigger_Error___ -ErrorAction Ignore } # 恢复$?

    return "${newLine}${pUserHost}${pVenv}${pCwd}${pGit}`n${pExitCode}${pChar}"
}.GetNewClosure()
```

几个细节：

1. 退出码必须在一开始就捕获。因为你在Prompt里调用任何别的命令，都有可能把它覆盖掉。

2. 设置环境变量`DISABLE_UNTRACKED_FILES_DIRTY`来阻止耗时的`git status`命令

3. 脚本在最后显式恢复了`$LASTEXITCODE`和`$?`。我看了很多自定义Prompt，都没做这个事。在现在这个大家都用codex和cc的时代，AI会经常依赖`$LASTEXITCODE`和`$?`。如果你不恢复，可能给AI带来很大的困扰。

## 命令补全设置

个人喜好Linux风格的补全：

```ps1
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
```

## fzf lazy load

[posh-fzf]加载的速度肯定不算很快，因此，只有真的按到快捷键时，才去初始化[posh-fzf]。

```ps1
$fzfState = @{ Loaded = $false }
$lazyLoadFzf = {
    if (-not $fzfState.Loaded) {
        $initLines = posh-fzf init
        $initCode = [string]::Join([System.Environment]::NewLine, $initLines)
        $initCode = $initCode.Replace('$null = New-Module', 'New-Module')
        $module = [scriptblock]::Create($initCode).InvokeReturnAsIs()
        Import-Module -ModuleInfo $module -Global
        $fzfState.Loaded = $true
    }
}.GetNewClosure()

Set-PSReadLineKeyHandler -Key 'Ctrl+t' -ScriptBlock {
    & $lazyLoadFzf
    Invoke-PoshFzfSelectItems
}.GetNewClosure()

Set-PSReadLineKeyHandler -Key 'Alt+c' -ScriptBlock {
    & $lazyLoadFzf
    Invoke-PoshFzfChangeDirectory
}.GetNewClosure()

Set-PSReadLineKeyHandler -Key 'Ctrl+r' -ScriptBlock {
    & $lazyLoadFzf
    Invoke-PoshFzfSelectHistory
}.GetNewClosure()
```

- `Ctrl+t`：选文件。
- `Alt+c`：切目录。
- `Ctrl+r`：搜索命令历史。

此外，`posh-fzf init`返回的字符串会加载一个匿名模块，由于我们在匿名`CommandBlock`中，把匿名模块加载到全局不太方便——那为什么不直接修改它的字符串呢？

:::NOTE
同样的，我们使用.NET函数来加速，而非像下面这么写：
```ps1
$initCode = posh-fzf init | Out-String
$initCode = $initCode.Replace('$null = New-Module', 'New-Module')
Invoke-Expression $initCode | Import-Module -Global
```
:::

## 按下空格自动纠错

```ps1
$AutoCorrectDict = if ($IsWindows) {
    [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
} else {
    [System.Collections.Generic.Dictionary[string, string]]::new()
}
# Typo -> Correct
$AutoCorrectDict.Add('gsduo', 'gsudo')
$AutoCorrectDict.Add('gsuod', 'gsudo')
$AutoCorrectDict.Add('gusdo', 'gsudo')
$AutoCorrectDict.Add('sduo', 'sudo')
$AutoCorrectDict.Add('suod', 'sudo')
$AutoCorrectDict.Add('usdo', 'sudo')
$AutoCorrectDict.Add(',', '.')

Set-PSReadLineKeyHandler -Key Spacebar -BriefDescription "AutoCorrectTypo" -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($cursor -gt 0) {
        $lastSpace = $line.LastIndexOf(' ', $cursor - 1)
        $wordStart = $lastSpace + 1
        $wordLen = $cursor - $wordStart
        if ($wordLen -gt 0) {
            $word = $line.Substring($wordStart, $wordLen)
            $correctWord = $null
            if ($AutoCorrectDict.TryGetValue($word, [ref]$correctWord)) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace($wordStart, $wordLen,$correctWord)
            }
        }
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
}.GetNewClosure()
```

Windows下不区分大小写。另外，`sudo`真的很容易拼错啊！

## 给gsudo注入补全能力

在前面套了一层`gsudo`之后，后面的命令补全体验就变差了。

因此，笔者手动给`gsudo` / `sudo`注册了参数补全器。思路是：

- 先把整条命令行拿到。
- 去掉前面的`gsudo`。
- 把后面的真实命令交给PowerShell自己的 `TabExpansion2`。
- 再把补全结果包装成新的`CompletionResult`返回。

```ps1
Register-ArgumentCompleter -Native -CommandName gsudo, sudo -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $commandLine = $commandAst.ToString()
    $firstSpaceIndex = $commandLine.IndexOf(' ')
    if ($firstSpaceIndex -gt 0) {
        # 多余的空格
        $innerStart = $firstSpaceIndex
        while ($innerStart -lt $commandLine.Length -and $commandLine[$innerStart] -eq ' ') {
            $innerStart++
        }

        if ($innerStart -lt $commandLine.Length) {
            $innerCommand = $commandLine.Substring($innerStart)
            $innerCursorPos = $cursorPosition - $innerStart
            $results = TabExpansion2 -inputScript $innerCommand -cursorColumn $innerCursorPos
            if ($results.CompletionMatches) {
                $list = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new($results.CompletionMatches.Count)
                foreach ($match in $results.CompletionMatches) {
                    $list.Add([System.Management.Automation.CompletionResult]::new(
                        $match.CompletionText,
                        $match.ListItemText,
                        $match.ResultType,
                        $match.ToolTip
                    ))
                }
                return $list
            }
        }
    }
}
```

:::NOTE
这个功能似乎可以通过[gsudo]的官方方式`Import-Module 'gsudoModule.psd1'`实现。官方的实现应该会更好一些。
:::

## 目录列表着色与默认编辑器

```ps1
Set-Alias l Get-ChildItemColorFormatWide
Set-Alias ls Get-ChildItemColorFormatWide
Set-Alias ll Get-ChildItemColor

if ($null -eq $env:EDITOR) {
    $env:EDITOR = "nvim"
}
```

第一块是把 `l`、`ls`、`ll` 统一到带颜色输出的版本。

第二块是给 `$env:EDITOR` 一个默认值，方便各种依赖这个环境变量的工具直接调用编辑器。此外，在命令输入界面，直接按下`Ctrl+x,Ctrl+e`，`PSReadLine`会允许你在`$Env:EDITOR`中编辑当前命令。

如果你不是`nvim`用户，把它换成`code --wait`、`notepad`或别的都行。

## 放进配置文件

脚本写好之后，别忘了把它放进PowerShell的配置文件。

直接打开并编辑，然后保存就行：

```ps1
notepad $PROFILE
```

:::NOTE
`$PROFILE`的父目录`Split-Path -Parent $PROFILE`可能不存在，你需要手动创建一下：

```ps1
New-Item -Type Directory -Path (Split-Path -Parent $PROFILE)
```
:::

然后把整份脚本内容贴进去，重新打开PowerShell即可。

如果想边改边试，也可以直接执行：

```ps1
. $PROFILE
```

# 完整内容

```ps1
# 前置需要：
# winget install gsudo
# cargo install posh-fzf
# Install-Module -Name Get-ChildItemColor
if (-not $Host.UI -or $Host.Name -notmatch 'ConsoleHost') { return }

# 防止污染命名空间
& {

$data = @{
    LeafDir = "";
    HasGit = $null;
    IsFirstPrompt = $true;
    ManualTitle = $null;
    LastWindowTitle = $null;
    LastGitProbePath = $null;
    LastGitDir = $null;
}

#region 快捷键设置
# 必须首先执行，否则会被覆盖
Set-PSReadLineOption -EditMode Emacs
#Set-PSReadLineKeyHandler -Key 'Ctrl+u' -Function BackwardKillLine # 目前的PSReadLine有BUG，无法正常运行这个Function
Set-PSReadLineKeyHandler -Key 'Ctrl+Enter' -Function AddLine
Set-PSReadLineKeyHandler -Key 'Ctrl+v' -Function Paste
Set-PSReadLineKeyHandler -Key 'Shift+Insert' -Function Paste
Set-PSReadLineKeyHandler -Key "Ctrl+Delete" -Function KillWord
Set-PSReadLineKeyHandler -Key "Ctrl+Backspace" -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+y' -Function Redo

#endregion

#region 别名展开
Set-PSReadLineKeyHandler -Key 'Alt+e' -BriefDescription "ExpandAliases" -LongDescription "展开当前命令行中的所有别名" -ScriptBlock {
    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
    $cmdFlag = [System.Management.Automation.Language.TokenFlags]::CommandName
    $aliasType = [System.Management.Automation.CommandTypes]::Alias
    $startAdjustment = 0
    $newCursor = $cursor
    foreach ($token in $tokens) {
        if ($token.TokenFlags -band $cmdFlag) {
            $aliasInfos = @($ExecutionContext.InvokeCommand.GetCommands($token.Text, $aliasType, $false))
            if ($aliasInfos.Count -gt 0) {
                $resolvedCommand = $aliasInfos[0].Definition
                if (![string]::IsNullOrEmpty($resolvedCommand)) {
                    $origStart = $token.Extent.StartOffset
                    $origEnd = $token.Extent.EndOffset
                    $origLength = $origEnd - $origStart
                    $start = $origStart + $startAdjustment
                    $diff = $resolvedCommand.Length - $origLength
                    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($start, $origLength, $resolvedCommand)
                    $startAdjustment += $diff
                    if ($cursor -ge $origEnd) {
                        $newCursor += $diff
                    } elseif ($cursor -gt $origStart -and $cursor -lt $origEnd) {
                        $newCursor = $origEnd + $startAdjustment
                    }
                }
            }
        }
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($newCursor)
}
#endregion

#region 自定义标题
$writeTitle = {
    param([Parameter(Mandatory)][string] $Title)
    if ($data.LastWindowTitle -eq $Title) { return }
    try { $Host.UI.RawUI.WindowTitle = $Title } catch { $null = $_ }
    try { [Console]::Write("`e]0;$Title`a") } catch { $null = $_ }
    $data.LastWindowTitle = $Title
}.GetNewClosure()

Set-Item -Path Function:\global:Set-Title -Value {
    param([Parameter(Mandatory)][string] $Title)
    $data.ManualTitle = $Title
}.GetNewClosure()

Set-Item -Path Function:\global:Clear-Title -Value {
    $data.ManualTitle = $null
}.GetNewClosure()
#endregion

#region 自定义prompt
$env:VIRTUAL_ENV_DISABLE_PROMPT = $true

$cReset   = "`e[0m"
$cGreen   = "`e[32m"
$cCyan    = "`e[36m"
$cYellow  = "`e[33m"
$cBlue    = "`e[34m"
$cRed     = "`e[31m"
$cMagenta = "`e[35m"
$fBold    = "`e[1m"
$fNormal  = "`e[22m"

$isAdmin = $false
$version = $PSVersionTable.PSVersion
if ($version.Major -eq 7 -and $version.Minor -ge 4) {
    $isAdmin = [System.Environment]::IsPrivilegedProcess
} else {
    if ($IsWindows) {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $isAdmin = [Security.Principal.WindowsPrincipal]::new($identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } elseif ($IsLinux -or $IsMacOS) {
        $isAdmin = (id -u) -eq 0
    }
}
if ($isAdmin) {
    $cUsername = $cRed
    $pChar = "${cReset}PS${cRed}${fBold}# ${cReset}${fNormal}"
    $titleAdminWarn = "Adm: "
} else {
    $cUsername = $cBlue
    $pChar = "${cReset}PS${cBlue}${fBold}> ${cReset}${fNormal}"
    $titleAdminWarn = ""
}
$user = [Environment]::UserName
$hostName = [System.Net.Dns]::GetHostName()
$pUserHost = "${cUsername}${fBold}${user}@${hostName}${cReset}${fNormal}"
$shell = [System.Diagnostics.Process]::GetCurrentProcess().ProcessName

# 先判断是否在仓库内，再决定是否调用git
$getGitDirFast = {
    $pwdInfo = $PWD
    if ($pwdInfo.Provider.Name -ne 'FileSystem') {
        return $null
    }
    $currentDir = $pwdInfo.ProviderPath
    while (-not [string]::IsNullOrEmpty($currentDir)) {
        $dotGit = [System.IO.Path]::Combine($currentDir, '.git')
        if ([System.IO.Directory]::Exists($dotGit) -or [System.IO.File]::Exists($dotGit)) {
            return $dotGit
        }
        $currentDir = [System.IO.Path]::GetDirectoryName($currentDir)
    }
    return $null
}.GetNewClosure()

Set-Item -Path Function:\prompt -Value {
    # 必须在最前面捕获
    $lastSuccess = $?
    $lastExit = $LASTEXITCODE

    if ($data.HasGit -eq $null) {
        $data.HasGit = [bool](Get-Command git -CommandType Application -ErrorAction Ignore)
    }

    # 虚拟环境
    $pVenv = ""
    if ($env:VIRTUAL_ENV) {
        $venvName = [System.IO.Path]::GetFileName($env:VIRTUAL_ENV)
        $pVenv = " ${cMagenta}(${venvName})${cReset}"
    }

    # 当前工作目录
    $cwd = $PWD.ProviderPath
    if ($cwd.StartsWith($HOME)) {
        $cwd = "~" + $cwd.Substring($HOME.Length)
    }
    $pCwd = " ${cReset}${fBold}${cwd}${cReset}${fNormal}"

    # Git分支信息
    $pGit = ""
    if ($data.HasGit) {
        $probePath = $PWD.ProviderPath
        if ($data.LastGitProbePath -eq $probePath) {
            $gitDir = $data.LastGitDir
        }
        else {
            $gitDir = & $getGitDirFast
            $data.LastGitProbePath = $probePath
            $data.LastGitDir = $gitDir
        }
        
        if ($gitDir) {
            $realGitDir = $gitDir
            if ([System.IO.File]::Exists($gitDir)) {
                try {
                    $gitdirContent = [System.IO.File]::ReadAllText($gitDir)
                    if ($gitdirContent.StartsWith("gitdir: ")) {
                        $targetDir = $gitdirContent.Substring(8).Trim()
                        if ([System.IO.Path]::IsPathRooted($targetDir)) {
                            $realGitDir = $targetDir
                        } else {
                            $gitParent = [System.IO.Path]::GetDirectoryName($gitDir)
                            $realGitDir = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($gitParent, $targetDir))
                        }
                    }
                } catch { }
            }

            $branch = 'unknown'
            $headFile = [System.IO.Path]::Combine($realGitDir, 'HEAD')
            if ([System.IO.File]::Exists($headFile)) {
                try {
                    $headContent = [System.IO.File]::ReadAllText($headFile).Trim()
                    if ($headContent.StartsWith('ref: refs/heads/')) {
                        $branch = $headContent.Substring(16)
                    } elseif ($headContent -match '^[0-9a-fA-F]{40}$') {
                        $branch = $headContent.Substring(0, 7)
                    } else {
                        $branch = 'detached'
                    }
                } catch { }
            }

            $dirtyMarker = ""
            $disableDirty = [bool](-not [string]::IsNullOrWhiteSpace($env:DISABLE_UNTRACKED_FILES_DIRTY)) -and 
                            ($env:DISABLE_UNTRACKED_FILES_DIRTY -ne 'false') -and 
                            ($env:DISABLE_UNTRACKED_FILES_DIRTY -ne '0')
            if (-not $disableDirty) {
                $statusOutput = git --no-optional-locks status --porcelain -uno 2>$null
                if ($LASTEXITCODE -eq 0 -and $statusOutput) {
                    $dirtyMarker = "${cRed}*${cYellow}"
                }
            }
            $pGit = " ${cYellow}git:(${branch}${dirtyMarker})${cReset}"
        }
    }

    # 退出码
    $pExitCode = ""
    if ($lastSuccess) {
        $pExitCode = "${cGreen}(0)${cReset} "
    } else {
        $displayCode = if ($lastExit) { $lastExit } else { "X" }
        $pExitCode = "${cRed}($displayCode)${cReset} "
    }

    # 刚刚打开终端不换行、刚刚clear了不换行
    $pos = $Host.UI.RawUI.CursorPosition
    $justCleared = ($pos.X -eq 0 -and $pos.Y -eq 0)
    $newLine = if ($data.IsFirstPrompt -or $justCleared) { "" } else { "`n" }
    $data.IsFirstPrompt = $false

    # 标题
    if ($null -eq $data.ManualTitle) {
        $data.LeafDir = if ($cwd -eq "~") { "~" } else { [System.IO.Path]::GetFileName($cwd) }
        & $writeTitle "${titleAdminWarn}${shell} $($data.LeafDir)"
    }
    else {
        & $writeTitle $data.ManualTitle
    }

    # 恢复被篡改的关键变量
    $global:LASTEXITCODE = $lastExit
    if ($lastSuccess) { $null = 1 } else { Get-Variable ___Magic_Var_To_Trigger_Error___ -ErrorAction Ignore } # 恢复$?

    return "${newLine}${pUserHost}${pVenv}${pCwd}${pGit}`n${pExitCode}${pChar}"
}.GetNewClosure()

#endregion

#region 命令补全设置
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
#endregion

#region 加载fzf
$fzfState = @{ Loaded = $false }
$lazyLoadFzf = {
    if (-not $fzfState.Loaded) {
        $initLines = posh-fzf init
        $initCode = [string]::Join([System.Environment]::NewLine, $initLines)
        $initCode = $initCode.Replace('$null = New-Module', 'New-Module')
        $module = [scriptblock]::Create($initCode).InvokeReturnAsIs()
        Import-Module -ModuleInfo $module -Global
        $fzfState.Loaded = $true
    }
}.GetNewClosure()

Set-PSReadLineKeyHandler -Key 'Ctrl+t' -ScriptBlock {
    & $lazyLoadFzf
    Invoke-PoshFzfSelectItems
}.GetNewClosure()

Set-PSReadLineKeyHandler -Key 'Alt+c' -ScriptBlock {
    & $lazyLoadFzf
    Invoke-PoshFzfChangeDirectory
}.GetNewClosure()

Set-PSReadLineKeyHandler -Key 'Ctrl+r' -ScriptBlock {
    & $lazyLoadFzf
    Invoke-PoshFzfSelectHistory
}.GetNewClosure()
#endregion

#region 命令纠错
$AutoCorrectDict = if ($IsWindows) {
    [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
} else {
    [System.Collections.Generic.Dictionary[string, string]]::new()
}
# Typo -> Correct
$AutoCorrectDict.Add('gsduo', 'gsudo')
$AutoCorrectDict.Add('gsuod', 'gsudo')
$AutoCorrectDict.Add('gusdo', 'gsudo')
$AutoCorrectDict.Add('sduo', 'sudo')
$AutoCorrectDict.Add('suod', 'sudo')
$AutoCorrectDict.Add('usdo', 'sudo')
$AutoCorrectDict.Add(',', '.')

Set-PSReadLineKeyHandler -Key Spacebar -BriefDescription "AutoCorrectTypo" -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($cursor -gt 0) {
        $lastSpace = $line.LastIndexOf(' ', $cursor - 1)
        $wordStart = $lastSpace + 1
        $wordLen = $cursor - $wordStart
        if ($wordLen -gt 0) {
            $word = $line.Substring($wordStart, $wordLen)
            $correctWord = $null
            if ($AutoCorrectDict.TryGetValue($word, [ref]$correctWord)) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace($wordStart, $wordLen,$correctWord)
            }
        }
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
}.GetNewClosure()

#endregion

#region 给gsudo注入补全能力
Register-ArgumentCompleter -Native -CommandName gsudo, sudo -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $commandLine = $commandAst.ToString()
    $firstSpaceIndex = $commandLine.IndexOf(' ')
    if ($firstSpaceIndex -gt 0) {
        # 多余的空格
        $innerStart = $firstSpaceIndex
        while ($innerStart -lt $commandLine.Length -and $commandLine[$innerStart] -eq ' ') {
            $innerStart++
        }

        if ($innerStart -lt $commandLine.Length) {
            $innerCommand = $commandLine.Substring($innerStart)
            $innerCursorPos = $cursorPosition - $innerStart
            $results = TabExpansion2 -inputScript $innerCommand -cursorColumn $innerCursorPos
            if ($results.CompletionMatches) {
                $list = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new($results.CompletionMatches.Count)
                foreach ($match in $results.CompletionMatches) {
                    $list.Add([System.Management.Automation.CompletionResult]::new(
                        $match.CompletionText,
                        $match.ListItemText,
                        $match.ResultType,
                        $match.ToolTip
                    ))
                }
                return $list
            }
        }
    }
}
#endregion

}
#region 加载Get-ChildItemColor
Set-Alias l Get-ChildItemColorFormatWide
Set-Alias ls Get-ChildItemColorFormatWide
Set-Alias ll Get-ChildItemColor
#endregion

if ($null -eq $env:EDITOR) {
    $env:EDITOR = "nvim"
}

if ([System.IO.File]::Exists("$HOME\scoop\shims\curl.exe")) { Set-Alias curl "$HOME\scoop\shims\curl.exe" }

```

启动速度真的很快！

<!-- 引用 -->

[效果]: ./效果.png "效果"
[gsudo]: https://gerardog.github.io/gsudo/ "gsudo官方网页与说明"
[posh-git]: https://github.com/dahlbyk/posh-git "A PowerShell environment for Git"
[posh-fzf]: https://github.com/domsleee/posh-fzf "Fzf keybinding integration for powershell"