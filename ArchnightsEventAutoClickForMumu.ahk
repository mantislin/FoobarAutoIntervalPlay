#Persistent
SendMode Event ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
SetTitleMatchMode "Slow"
DetectHiddenText "On"
DetectHiddenWindows "On"

if not A_IsAdmin
{
    Run "RunAs *" . A_ScriptFullPath
    ExitApp
}

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �˽ű���Ҫ���ܣ�
;       MuMuģ���������շ��۵��Զ�ѭ�����
; ��ݼ�˵����
;       ).��ݼ� Ctrl+Shift+Alt+0 ��ʼ����ѭ���������ʼ�ж�����ť��λ�ã��ɹҺ�̨�޴���
;       ).��ݼ� Ctrl+Shift+Alt+9 ֹͣ����ѭ���������ʼ�ж�����ť��λ�ã��ɹҺ�̨�޴���
;       ).��MuMuģ�����ķ�����Ϸ�ڰ�`����ģ�������ϽǺ��˰�ť��λ��

global ahkTitle:="ArchnightsEventHelper"
global appTitle:="���շ��� - MuMuģ���� ahk_class Qt5QWindowIcon"
global archnightsInterval:=5000
global cycling:=0
global cyclingLast:=0

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;; shortkeys for ArchnightsEventHelper
;; ���ò���:
;;   /start
;;   /stop
archnights(command)
{
    if (command = "stop") {
        cycling:=0
    } else {
        cycling:=1
    }

    if (cycling = 0) {
        TrayTip ahkTitle,"ArchnightsEventHelper stopped",3
        SetTimer "CycleArchnightsEventHelper",0
    } else if (cycling = cyclingLast) {
        TrayTip ahkTitle,"ArchnightsEventHelper is already running",3
    } else {
        TrayTip ahkTitle,"ArchnightsEventHelper started",3
        CycleArchnightsEventHelper()
        SetTimer "CycleArchnightsEventHelper",archnightsInterval
    }

    cyclingLast:=cycling
}
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
CycleArchnightsEventHelper()
{
    if (cycling != 0) {
        if WinWait(appTitle,,3) {
            TrayTip ahkTitle,"Sending click",3
            SetControlDelay -1
            ;ControlClick "x1222 y751",appTitle,,,,"NA"
            PostClick(RelativeX(1240),RelativeY(751),appTitle)
        } else {
            TrayTip ahkTitle,"No Mumu Simulater Window Found",3
        }
    }
}
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
PostClick(x,y,win:="A")
{
    lParam:=x&0xFFFF|(y&0xFFFF)<<16
    PostMessage 0x201,,lParam,,win ;WM_LBUTTONDOWN
    PostMessage 0x202,,lParam,,win ;WM_LBUTTONUP
}
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
RelativeX(xOrigin)
{
    WinGetPos x,y,width,height,appTitle
    return xOrigin/1440*width
}
RelativeY(yOrigin)
{
    offset:=35
    WinGetPos x,y,width,height,appTitle
    result:=(yOrigin-offset)<0 ? 0 : yOrigin-offset
    result:=result/(899-offset)*(height-offset)
    result:=result+offset
    return result
}
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
isFormationPage()
{
    ;��ݱ��ҳ
    ;985,70,0xDC9800
    ;1370,80,0x00007D
    ;1200,80,0x313131

    ;1202,701,0xFFFFFF
    ;1202,701,0x1D****/0x1E****

    ;1170-1315
}
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
^+!0::archnights("start") ;Ctrl+Shift+Alt+0 �����Զ����
^+!9::archnights("stop") ;Ctrl+Shift+Alt+9 �ر��Զ����
#If WinActive(appTitle)
{
    `::PostClick(RelativeX(80),RelativeY(80),appTitle) ;��`��������Ͻǵĺ��˰�ť
}
