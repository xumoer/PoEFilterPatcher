/*
Filter Updater for NeverSink's-Filter Version 0.1.2
Currently Functional
Needs better Documentation
Author: Xumoer

*/


#NoEnv
#SingleInstance force
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
global CVersion = 0
Menu, Tray, Add, Settings
Menu, Tray, Add, Version Check, VCheck
_Versions := ["REGULAR", "SEMI-STRICT", "STRICT", "VERY-STRICT", "UBER-STRICT", "UBER-PLUS-STRICT"] ;setup for arrays
_Styles := ["BLUE", "PURPLE", "SLICK", "STREAMSOUND", "REGULAR"] 
_Vstate := []
_Sstate := []
vstate := {}
Sstate := {}
IfNotExist, FAUsettings.ini
{
	for index, element in _Versions
		{
		IniWrite, 0, FAUsettings.ini, versions, %element%
		}

	for index, element in _Styles
		{
		IniWrite, 0, FAUsettings.ini, styles, %element%
		}
	Iniwrite, %CVersion%, FAUsettings.ini, Current, VERSION
}


Settings:
ReadConfig()
	iG := _Versions.MaxIndex() * 24 > _Styles.MaxIndex() * 24 ? _Versions.MaxIndex() * 24 : _styles.MaxIndex() * 24 ; math for gui format, sets each Groupbox to the size of the largest array
	Gui, 1:add, GroupBox, xm ym Section w160 h%iG%,Versions
		for index, element in _Versions
		{
			i += 20
			vstate := {(_Versions[index]):(_vstate[index])}     ;can't use an multidimentional-array as the gui control var. This lets us create an array with the state we choose.
			Checkedstate := vstate[element]
			Gui, 1:add, Checkbox, Checked%Checkedstate% vvstate%index%  xs+10 ys+%i% , %element%    
		}
		i = 0
	Gui, 1:add, GroupBox, x185 ym Section w160 h%iG%, Styles
		for index, element in _Styles
		{
			i += 20
			sstate := {(_Styles[index]):(_sstate[index])}
			Checkedstate := sstate[element]
			Gui, 1:add, Checkbox,Checked%Checkedstate%	vsstate%index% xs+10 ys+%i%, %element%
		}
Gui, 1:add, Button, xm gSave vSave  , Save
Save_TT := "Saves the currently selected options."
Gui, 1:add, Button, gVCheck vVCheck x+5, Version Check
VCheck_TT := "Checks the currently installed version of the NeverSink-Filter versus the newest release on github.`nAlso Saves the current configuration of filter options."
Gui, 1:add, Button, gAddFilters vAddFilters x+5, Extract New Filters
AddFilters_TT := "If the newest version is already downloaded this will extract the selected filters."
Gui, 1:add, Button, gDelete vDelete x+5, Delete
Delete_TT := "Deletes current configuration of filters."
Gui, Show, , Filter Updater - Installed Version:%IVersion%


OnMessage(0x200, "WM_MOUSEMOVE")
return

WM_MOUSEMOVE()
{
    static CurrControl, PrevControl, _TT
    CurrControl := A_GuiControl
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip  
        SetTimer, DisplayToolTip, 500
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    ToolTip % %CurrControl%_TT  
    return
}


VCheck:
{
	Submit()
IfExist, Versionhtml.txt
	FileDelete, Versionhtml.txt

UrlDownloadToFile, https://github.com/NeverSinkDev/NeverSink-Filter/releases/latest, Versionhtml.Txt
IfExist, Versionhtml.txt
		{
	Loop, read, Versionhtml.txt
	{
		FoundPos := RegExMatch(A_LoopReadLine, "(\/+\d+\.)+(\d+\.?)?(\d)", FoundString)
		if (FoundPos != 0)
			{
				StringTrimLeft, CVersion, Foundstring, 1
				Break
			}
		}
	}


if (CVersion == IVersion)
	{
	TrayTip, Current Version:%A_Space%%CVersion%, You have the current filter version!, , 1
	global NeedUpdate := 0
	}
	Else
	{
		IfExist, %A_ScriptDir%\%CVersion%.zip
		{
			Msgbox, 4, Installed Version:%A_Space%%IVersion%, You have the new version downloaded already.`nWould you like to extract selected filters?
			IfMsgBox, Yes
			Update()
		}
		else{
	Msgbox, 4, Installed Version:%A_Space%%IVersion%, Theres is a new Version(%CVersion%)`nWould you like to download it?
	IfMsgBox, Yes
	Update()
		}
	}
Return
}

Submit(){
	Save:
	global
	Gui, 1:Submit, NoHide

	ALO()
	if (sumed > 0)
	{
	for index, element in _Versions
	{
		i := vstate%index%
		IniWrite, %i%, FAUsettings.ini, versions, %element%
	}
	for index, element in _Styles
	{
		i := sstate%index%
		IniWrite, %i%, FAUsettings.ini, styles, %element%
	}
	return
	}
		return
}

ReadConfig(){
	global
	for index, element in _Versions
	{
		IniRead, i, FAUsettings.ini, versions, %element%
		_vstate[index] := i
		vstate%index% := i
	}
	for index, element in _Styles
	{
		IniRead, i, FAUsettings.ini, styles, %element%
		_sstate[index] := i
		sstate%index% := i
	}
	iniread, IVersion, FAUsettings.ini, Current, VERSION
}
Return

Update(){
	global
	IfnotExist, %A_ScriptDir%\%CVersion%.zip
	UrlDownloadToFile, https://github.com/NeverSinkDev/NeverSink-Filter/archive/%CVersion%.zip, %CVersion%.zip
	
	sleep, 1000
	
	IfExist, %A_ScriptDir%\%CVersion%.zip
		{
			for index, element in _Versions
			{
				if (vstate%index% = 1)
				{
					_VERNUM := index
					
					for index, element in _Styles
					{
						if (sstate%index% = 1)
						{
							Vreg := element
							 if (Vreg = "REGULAR")
							 {
							 test := A_ScriptDir . "\7za.exe e " . CVersion . ".zip " . """NeverSink-Filter-" . CVersion . "/*" . _VERNUM . "*.filter"""
							 Run, %test%
							 }
							 else{
								test := A_ScriptDir . "\7za.exe e " . CVersion . ".zip " . """NeverSink-Filter-" . CVersion . "/(STYLE) " . element . "/*" . _VERNUM . "*.filter"""
								Run, %test%
							}
						}
					}
				}
			}
		}
		IniWrite, %CVersion%, FAUsettings.ini, Current, VERSION ;IVersion, FAUsettings.ini, Current, VERSION
		IVersion := CVersion
}
Return

delete:
IfnotExist, %A_ScriptDir%\*.filter
	return

Submit()


for index, element in _Versions
	{
		if (vstate%index% = 1)
			{
				_VERNUM := index
					
				for index, element in _Styles
				{
					if (sstate%index% = 1)
					{
						Vreg := element
						 if (Vreg = "REGULAR")
						 {
						 test := "NeverSink's Filter - " . _VERNUM . "-" . _Versions[_VERNUM]  . ".filter"
						 FileDelete, %test%
						 }
						 else{
							test := "NeverSink's Filter - " . _VERNUM . "-" . _Versions[_VERNUM] . " (" . element . ") " . ".filter"
							FileDelete, %test%
						}
					}
				}
			}
		}
	

Return

ExFilters()
{
global
AddFilters:
Submit()
msgbox, %IVersion%
IfExist, %A_ScriptDir%\%IVersion%.zip
		{
			for index, element in _Versions
			{
				if (vstate%index% = 1)
				{
					_VERNUM := index
					for index, element in _Styles
					{
						if (sstate%index% = 1)
						{
							Vreg := element
							 if (Vreg = "REGULAR")
							 {
							 test := A_ScriptDir . "\7za.exe e " . IVersion . ".zip " . """NeverSink-Filter-" . IVersion . "/*" . _VERNUM . "*.filter"""
							 Run, %test%
							 }
							 else{
								test := A_ScriptDir . "\7za.exe e " . IVersion . ".zip " . """NeverSink-Filter-" . IVersion . "/(STYLE) " . element . "/*" . _VERNUM . "*.filter"""
								Run, %test%
							}
						}
					}
				}
			}
		}
	Return
}


ALO()
{
	global
	Sums := 0
	Sumv := 0

	for index, element in _styles
	{
	Sums := Sums + sstate%index%
	}
	for index, element in _Versions
	{
	Sumv := Sumv + vstate%index%
	}

if (Sums = 0)
{
msgbox, Please select at least one Style.
sumed := 1
return
}

if (Sumv = 0)
{
	msgbox, Please select at least one Version.
	sumed := 1
	return
}
}

GuiClose:
gui, Destroy
return