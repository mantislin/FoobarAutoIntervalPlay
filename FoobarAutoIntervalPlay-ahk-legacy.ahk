#Persistent
;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Play ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
;SetTitleMatchMode RegEx
SetTitleMatchMode "Slow"
DetectHiddenText true
DetectHiddenWindows true

if not A_IsAdmin
{
    Run "RunAs *" . A_ScriptFullPath
    ExitApp
}

global cycling:=0
global ahkTitle:="FoobarHelper"

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;; shortkeys for foobar2000_dreamix
;; 可用参数:
;;   /add <文件列表> - 添加指定的文件替换当前列表的内容并立即播放
;;   /immediate - 当添加文件时不显示 "请稍候" 对话框
;;   /play，/pause，/playpause，/prev，/next，/rand，/stop - 播放控制
;;   /exit - 退出 foobar2000
;;   /show，/hide - 显示或隐藏 foobar2000 主窗口
;;   /config - 打开参数选项窗口
;;   /command:<菜单命令> - 执行指定的主菜单命令
;;   /playlist_command:<上下文菜单命令> - 在当前播放列表选定项执行指定的上下文菜单命令
;;   /playing_command:<上下文菜单命令> - 在当前正在播放的音轨执行指定的上下文菜单命令
;;   /context_command:<上下文菜单命令> <文件> - 在指定的文件执行指定的上下文菜单命令
foobar(command)       ; foobar2000 控制中枢
{
    if command = stop
    {
        cycling:=0
    }

    ; EnvGet,fbpath,scuts
    ; SetWorkingDir fbpath
    execDP:="D:\ProgramFiles\foobar\dreamix_v3.4"
    execDPNX:=Format("{1}\foobar2000.exe",execDP)
    ;TrayTip ahkTitle . ",Foobar command: " . command,3
    TrayTip execDPNX . "," . Format(" /{1}",command)
    Run execDPNX Format(" /{1}", command)
    SetWorkingDir A_ScriptDir
    return 0
}
^+!Insert::foobar("play")
^+!Home::  foobar("playpause")
^+!End::   foobar("stop")
^+!PgUp::  foobar("prev")
^+!PgDn::  foobar("next")
^+!Delete::foobar("rand")
^+!x::     foobar("exit")
^+!v::     foobar('command:"Stop after current"')
^+!w::     foobar('command:"Activate or Hide"')
^+!Up::    foobar('command:"Up"')                 ; 音量提高
^+!Down::  foobar('command:"Down"')               ; 音量降低
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; 这段用于处理“foobar2000 崩溃”时出现崩溃窗口的情况
; 处理方法为关闭此窗口并重新启动foobar 2000
^+!f::
;IfWinExist foobar2000 崩溃 ; 如果出现“foobar2000 崩溃”的窗口
if WinExist("foobar2000 崩溃") ; 如果出现“foobar2000 崩溃”的窗口
{
    ControlClick 取消,title,,,,NA ; 关闭错误窗口
    Run dreamix
    ; WinWait,foobar2000 非正常关闭,正常运行 foobar2000,5 ; 等待窗口出现 5 秒
    WinWait foobar2000,正常运行 foobar2000,5 ; 等待窗口出现 5 秒
    ControlClick 正常运行 foobar2000,foobar2000 非正常关闭,,,,NA
}
return

getStatus()
{
    ;IfWinExist ^foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}
    if WinExist("^foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}")
    return 2 ; foobar is running and stopped
    ;IfWinExist .* - foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}
    if WinExist(".* - foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}")
    return 1 ; foobar is running and playing
    return 0 ; foobar is not running
}

^+!Left::
myTitle:="Auto interval"
If cycling != 0
{
    cycling:=0
    TrayTip ahkTitle,myTitle . ":\nCharging stopped!",3
    SetTimer "AutoInterval","Off"
}
Else
{
    cycling:=1
    TrayTip ahkTitle,myTitle . ":\nCharging started!",3
    SetTimer "AutoInterval","On"
}
return

AutoInterval()
{
    myTitle:="Auto interval"
    intervalmin:=40
    intervalmax:=60
    ;IfWinExist,^foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}
    if WinExist("^foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}")
    {
        foobar("play")
        foobar('command:"Stop after current"')
        WinWait ".* - foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}",,5
        if ErrorLevel {
            ;MsgBox,0,Error!,Foobar start playing failed!,2
            TrayTip "ahkTitle,Foobar starts to play failed!",3
            cycling:=0
            return
        }
    }
    CycleFoobar
}

CycleFoobar()
{
    if cycling = 0
        return
    ;IfWinExist,^foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}
    if WinExist("^foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}")
    {
        WinWait "^foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}",,5
        if ErrorLevel
            goto CycleFoobar

            ;Random rand,intervalmin,intervalmax
            rand:=Random(intervalmin,intervalmax)
            ;intervalplay:=Rand(intervalmin,intervalmax)
            ;MsgBox,0,,"interval:".rand,2
            TrayTip "ahkTitle,next: after rand seconds.",3
            Sleep rand*1000
            if cycling = 0
                return
                foobar("play")
                foobar('command:"Stop after current"')
                WinWait ".* - foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}",,5
                if ErrorLevel {
                    ;MsgBox,0,Error!,Foobar start playing failed!,2
                    TrayTip "ahkTitle,Foobar start to play failed!",3
                    cycling:=0
                    return
                }
    }
    else if WinExist(".* - foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}")
    {
        WinWait ".* - foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}",,5
        if ErrorLevel
            goto CycleFoobar
            WinWait "^foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}"
    }
    else
    {
        foobar("play")
        foobar('command:"Stop after current"')
        WinWait ".* - foobar2000 ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}",,5
        if ErrorLevel {
            ;MsgBox,0,Error!,Foobar launches failed!,2
            TrayTip "ahkTitle,Foobar launches failed!",3
            cycling:=0
            return
        }
    }
    Sleep 500
    goto CycleFoobar
    return
}
