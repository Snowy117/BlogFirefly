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

    $startAdjustment = 0
    $newCursor = $cursor
    foreach ($token in $tokens) {
        if ($token.TokenFlags -band [System.Management.Automation.Language.TokenFlags]::CommandName) {
            $alias = Get-Command -Name $token.Text -CommandType Alias -ErrorAction SilentlyContinue
            if ($alias) {
                $resolvedCommand = $alias.Definition
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
    $cwd = $PWD.Path
    if ($cwd.StartsWith($HOME)) {
        $cwd = "~" + $cwd.Substring($HOME.Length)
    }
    $pCwd = " ${cReset}${fBold}${cwd}${cReset}${fNormal}"

    # Git分支信息
    $pGit = ""
    if ($data.HasGit) {
        $probePath = $PWD.Path
        if ($data.LastGitProbePath -eq $probePath) {
            $gitDir = $data.LastGitDir
        }
        else {
            $gitDir = & $getGitDirFast
            $data.LastGitProbePath = $probePath
            $data.LastGitDir = $gitDir
        }
        if ($gitDir) {
            $statusLines = @(git --no-optional-locks -c color.status=false status --short --branch -uno 2>$null)
            if ($LASTEXITCODE -eq 0 -and $statusLines.Count -gt 0) {
                $headLine = [string]$statusLines[0]
                $branch = $headLine
                if ($headLine.StartsWith('## ')) {
                    $branch = $headLine.Substring(3)
                }
                if ($branch -match '^(?<name>.+?)\.\.\..*$') {
                    $branch = $Matches.name
                }
                $branch = $branch.Trim()
                if ([string]::IsNullOrWhiteSpace($branch)) {
                    $branch = 'detached'
                }
                $dirtyMarker = if ($statusLines.Count -gt 1) { "${cRed}*${cYellow}" } else { "" }
                $pGit = " ${cYellow}git:(${branch}${dirtyMarker})${cReset}"
            }
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
        $initCode = posh-fzf init | Out-String
        $initCode = $initCode.Replace('$null = New-Module', 'New-Module')
        Invoke-Expression $initCode | Import-Module -Global
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
$AutoCorrectDict.Add('，', '.')

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

