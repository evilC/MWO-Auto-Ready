; MWO Intelligent Zoom

; Create an instance of the library
ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

; Buffer hotkeys - important, required so rolling mouse wheel up while already zooming queues a zoom
#MaxThreadsBuffer on
; Just in case I spin my mouse wheel in free-spinning mode ;)
#MaxHotkeysPerInterval 999

; Set up vars
calibrated := 0
heartbeat_ready := 0

; ============================================================================================
; CONFIG SECTION - Configure ADHD

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "MWO Ready", version: 0.1, author: "evilC", link: "<a href=""http://mwomercs.com/forums/topic/"">LINK! Homepage</a>"})
; The default application to limit hotkeys to.
; Starts disabled by default, so no danger setting to whatever you want
ADHD.config_default_app("CryENGINE")

; GUI size
ADHD.config_size(375,200)

; Defines your hotkeys 
; subroutine is the label (subroutine name - like MySub: ) to be called on press of bound key
; uiname is what to refer to it as in the UI (ie Human readable, with spaces)
ADHD.config_hotkey_add({uiname: "Calibrate", subroutine: "Calibrate"})

; Hook into ADHD events
; First parameter is name of event to hook into, second parameter is a function name to launch on that event
ADHD.config_event("app_active", "app_active_hook")
ADHD.config_event("app_inactive", "app_inactive_hook")
ADHD.config_event("option_changed", "option_changed_hook")
ADHD.config_event("resolution_changed", "resolution_changed_hook")

ADHD.init()

ADHD.create_gui()

; The "Main" tab is tab 1
Gui, Tab, 1
; ============================================================================================
; GUI SECTION

Gui, Add, Text, x5 yp+25, X
ADHD.gui_add("Edit", "ReadyX", "xp+10 yp-2 W40", "", "")
Gui, Add, Text, xp+45 yp+2, Y
ADHD.gui_add("Edit", "ReadyY", "xp+10 yp-2 W40", "", "")
Gui, Add, Text, xp+45 yp+2, Ready OFF
ADHD.gui_add("Edit", "ReadyOffCol", "xp+55 yp-2 W50", "", "")
Gui, Add, Text, xp+50 yp+2 W20 center vReadyOffColSwatch, ■
Gui, Add, Text, xp+25 yp, Ready ON
ADHD.gui_add("Edit", "ReadyOnCol", "xp+55 yp-2 W50", "", "")
Gui, Add, Text, xp+50 yp+2 W20 center vReadyOnColSwatch, ■

Gui, Add, Text, x5 yp+45, Status
ADHD.gui_add("DropDownList", "ReadyStatus", "xp+50 yp-2 W50", "Off||On", "Off")

; End GUI creation section
; ============================================================================================


ADHD.finish_startup()

return

Calibrate:
	; Detect mouse position
	MouseGetPos, mouse_x, mouse_y
	
	; Pixel below mouse should be "Not Ready" colour
	PixelGetColor, ready_off_colour, mouse_x, mouse_y, RGB
	; Remove 0x from start
	ready_off_colour := SubStr(ready_off_colour, 3)
	
	; Click mouse
	Click
	
	; Wait a little
	Sleep, 100
	
	; Find new "Ready" colour
	PixelGetColor, ready_on_colour, mouse_x, mouse_y, RGB
	; Remove 0x from start
	ready_on_colour := SubStr(ready_on_colour, 3)
		
	; Update settings
	GuiControl,,ReadyX,%mouse_x%
	GuiControl,,ReadyY,%mouse_y%
	GuiControl,,ReadyOffCol,%ready_off_colour%
	GuiControl,,ReadyOnCol,%ready_on_colour%
	
	;Gui, Submit, NoHide
	;update_swatches()
	option_changed_hook()
	
	return

update_swatches(){
	global ReadyOffCol
	global ReadyOnCol
	
	update_swatch("ReadyOffColSwatch", ReadyOffCol)
	update_swatch("ReadyOnColSwatch", ReadyOnCol)
}

update_swatch(swatch, col){
	
	tmp := "+c" col
	GuiControl, %tmp%, %swatch%
	GuiControl,, %swatch%, ■
	return
}
	
Heartbeat:
	PixelGetColor, tmp, ReadyX, ReadyY, RGB
	col := "0x" ReadyOffCol
	if (tmp == col){
		if (heartbeat_ready){
			Click, %ReadyX%, %ReadyY%
			Sleep, 1000
			PixelGetColor, tmp, ReadyX, ReadyY, RGB
			col := "0x" ReadyOnCol
			if (tmp == col){
				soundbeep, 800, 100
				ADHD.debug("Heartbeat detected good ready")
			} else {
				soundbeep, 500, 100
				ADHD.debug("Heartbeat detected bad ready?")
			}
			heartbeat_stop()
		} else {
			ADHD.debug("Heartbeat detected ready button, waiting for stability...")
			heartbeat_ready := 1
			Sleep, 1000
			Gosub, Heartbeat
		}
	} else {
		ADHD.debug("Heartbeat did not detect Ready button")
	}
	return

TimeOut:
	ADHD.debug("Heartbeat TimeOut - Stopping")

	heartbeat_stop()
	return
	
heartbeat_start(){
	global heartbeat_ready
	
	ADHD.debug("Starting Heartbeat")
	
	heartbeat_ready := 0
	SetTimer, Heartbeat, 1000
	SetTimer, TimeOut, 60000
	return
}
	
heartbeat_stop(){
	SetTimer, Heartbeat, Off

	ADHD.debug("Stopping Heartbeat")
	return
}
	
app_active_hook(){
	
}

app_inactive_hook(){

}

option_changed_hook(){
	global ADHD
	global ReadyX
	global ReadyY
	global ReadyOffCol
	global ReadyOnCol
	global calibrated
	
	heartbeat_stop()
	update_swatches()
	if (ReadyX == "" || ReadyY == "" || ReadyOffCol == "" || ReadyOnCol == ""){
		calibrated := 0
		GuiControl, Choose, ReadyStatus, Off
		GuiControl, +Disabled, ReadyStatus
		
	} else {
		calibrated := 1
		GuiControl, -Disabled, ReadyStatus
	}
}

; Fired when the limited app changes resolution. Useful for some games that have a windowed matchmaker and fullscreen game
resolution_changed_hook(){
	global ADHD
	global ReadyStatus
	
	Winget, tmp, MinMax
	ADHD.debug("winget reports " tmp)
	if (tmp == -1){
		return
	}
	curr_size := ADHD.limit_app_get_size()
	last_size := ADHD.limit_app_get_last_size()
	ADHD.debug("Res change: " last_size.w "x" last_size.h " --> " curr_size.w "x" curr_size.h )
	if (curr_size.w > last_size.w || curr_size.h > last_size.h){
		; Got larger - lobby to game
		ADHD.debug("MWOReady: Res got bigger")
		if (ReadyStatus == "On"){
			heartbeat_start()
		}
	} else if (curr_size.w < last_size.w || curr_size.h < last_size.h) {
		; Got smaller game to lobby
		ADHD.debug("MWOReady: Res got smaller")
		
		; Just in case...
		heartbeat_stop()
	}
	return
}
; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this
