#Persistent
;#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#WinActivateForce
; SendMode InputThenPlay ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.
;SetTitleMatchMode RegEx
SetTitleMatchMode "Slow"
DetectHiddenText "On"
DetectHiddenWindows "On"

; Launch lingoes if it's not running.
; Activate it if it's inactive.
; Minimize it if it's activate.
^+!L::
    lgpath:="programfiles\Lingoes\Translator2"
    lgmain:="Lingoes64.exe"
    lgprogram:="lgpath\lgmain"

    ; lgpath:=C:\WINDOWS ; testing
    ; lgmain:=notepad.exe ; testing
    ; lgprogram:=lgpath\lgmain ; testing

    ProcessExist lgmain

    lgpid:=ErrorLevel
    lgPidTitle:="Lingoes ahk_pid " . lgpid
    lgClassTitle:="Lingoes ahk_class Afx:00007FF[\d\S]{9}:0" ; Don't add quote for the regex

    ; lgPidTitle:=.*Notepad ahk_pid lgpid ; testing
    ; lgClassTitle:=Notepad ahk_class Notepad ; Don't add quote for the regex ; testing

    if lgpid = 0
    {
        Run "lgprogram"
        if ErrorLevel = ERROR {
            TrayTip "Lingoes,Run failed!",3
            return
        }
        WinWaitActive(lgClassTitle,,30)
        if ErrorLevel {
            TrayTip "Lingoes,Cannot activate lingoes!",3
        }
    }
    else
    {
        if WinWaitActive(lgPidTitle,,2)
        {
            SendInput "{Esc}"
            WinWaitNotActive "",,2
            if ErrorLevel
                TrayTip "Lingoes,Cannot hide lingoes!",3
        }
        else
        {
            if WinWait(lgPidTitle,,3) {
                Run "lgprogram"
                WinWaitActive(lgPidTitle,,2)
                if ErrorLevel
                    TrayTip "Lingoes,Cannot show lingoes!",3
            }
        }
    }
return

; <Ctrl + Alt + MouseLeft> == <MouseRight>
^!LButton::RButton

; Ctrl+Alt+Shift+T: open cmd.exe
;^+!T::Run comspec /k "cd/d `"`%userprofile`%`""
^+!T::Run A_ComSpec ' /k cd/d "%userprofile%"'

; Ctrl+Alt+Insert: open taskmgr.exe
; ^!Insert::Run,taskmgr

; Replace <Win+E>: open Windows Explorer and set focus to it after successfully opening it
#e::
    Run "::{20d04fe0-3aea-1069-a2d8-08002b30309d}"
    WinWait "This PC ahk_class CabinetWClass","",3
    if not ErrorLevel { ;for the unknown-reason focus losing of new window of Windows Explorer
        WinActivate
    }
return

; <Win + Delete> open taskmgr
#Delete::Run "taskmgr"

; restart Explorer
^+!r::
    RunWait "taskkill /im explorer.exe /f"
    if ErrorLevel {
        MsgBox "Failed","Cannot kill explorer.exe",5
        return
    }
    Run "explorer.exe"
return

; CCleaner测试
^!c::
    sw:="Piriform CCleaner"
    ;WinWait,sw,清洁器(&C),TL5
    ;IIfWinExist sw,分析(&A)
    if WinWait(sw,"分析(&A)",3)
        MsgBox "存在"
    else
        MsgBox "不存在"
    ; ControlClick,关闭,,,,,NA
    sw:=""
return

; CCleaner清理系统垃圾
^+!c::
    sw:="Piriform CCleaner"
    TL5:=5
    TL60:=60
    TL300:=300
    ; 打开sw，附加一定程度的检测是否正确打开功能
    ;IfWinNotExist sw
    ;{
    if WinWait(sw,,3) {
        ; Run,CCleaner,,Min
        Run CCleaner
        WinWait(sw,"",TL5)
        if ErrorLevel {
            MsgBox "CCleaner","打开sw超时！",TL5
            return
        }
    }
    ; =================================
    ; 开始清理垃圾
    WinWait sw,"清洁器(&C)",TL5
    if ErrorLevel {
        MsgBox "CCleaner","等待超时！",TL5
        return
    }
    ControlClick "清洁器(&C)",sw,,,,NA
    WinWaitActive sw,"分析(&A)",TL5
    if ErrorLevel {
        MsgBox "CCleaner","等待超时！",TL5
        return
    }
    ControlClick "分析(&A)",sw,,,,NA
    WinWait sw,"分析完成"
    ; 此ifwinnotexist表明检测到有垃圾
    WinWaitActive sw,"运行清洁器(&R)",TL60
    if ErrorLevel {
        MsgBox "CCleaner","等待超时！",TL5
        return
    }
    ControlClick "运行清洁器(&R)",sw,,,,NA
    WinWait sw,"清除完成"
    ; =================================
    ; 开始清理注册表
    ControlClick "注册表(&G)",sw,,,,NA
    WinWaitActive sw,"扫描问题(&S)",TL5
    If ErrorLevel {
        MsgBox "CCleaner","等待超时！",TL5
        return
    }
    ControlClick "扫描问题(&S)",sw,,,,NA
    WinWaitClose sw,"取消扫描(&C)",TL300
    If ErrorLevel {
        MsgBox "CCleaner","等待超时！",TL5
        return
    }
    WinWaitActive sw,"修复所选问题(&F)...",TL5
    ControlClick "修复所选问题(&F)...",sw,,,,NA
    WinWaitActive CCleaner,"否(&N)",TL5
    ; 此ErrorLevel表明没有发现问题
    if ErrorLevel {
        WinClose sw
        return
    }
    ControlClick "否(&N)",CCleaner,,,,NA
    WinWaitActive "修复问题",TL5
    WinWaitActive "修复所有选定的问题",,2
    If ErrorLevel
        ControlClick "修复所有选定的问题",,,,,NA
    else
        ControlClick "修复问题",,,,,NA
    WinWaitNotActive "修复问题",TL60
    ControlClick "关闭",,,,,NA
    WinClose sw
    sw:=""
    TL5:=0
    TL60:=0
    TL300:=0
    SetTitleMatchMode Fast
return

; 这段用于处理“foobar2000 崩溃”时出现崩溃窗口的情况
; 处理方法为关闭此窗口并重新启动foobar 2000
^+!f::
    ;IIfWinExist foobar2000 崩溃 ; 如果出现“foobar2000 崩溃”的窗口
    if WinExist("foobar2000 崩溃") {
        ControlClick "取消",title,,,,NA ; 关闭错误窗口
        Run "dreamix"
        ; WinWait,foobar2000 非正常关闭,正常运行 foobar2000,5 ; 等待窗口出现 5 秒
        WinWait "foobar2000","正常运行 foobar2000",5 ; 等待窗口出现 5 秒
        ControlClick "正常运行 foobar2000","foobar2000 非正常关闭",,,,NA
    }
return
