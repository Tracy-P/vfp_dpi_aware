*-- Vista popup menu artifact fix
If Os(3) = "6"
	Declare Integer GdiSetBatchLimit In WIN32API Integer
	GdiSetBatchLimit(1)
Endif

*-- Initial size of app
_vfp.Width = Sysmetric(1) * .5
_vfp.Height = Sysmetric(2) * .75
_vfp.Left = 0
_vfp.Top = 0
_Screen.Show()

Private goMainApplication
goMainApplication = Createobject("MainApplicationClass")
goMainApplication.ReadEvents()
On Shutdown



Define Class MainApplicationClass As Custom

	Procedure Error
		Lparameters errorNumber, methodName, lineNumber
		Local stackString
		stackString = "Error: " + Transform(errorNumber) + " " + Transform(Message()) + Chr(13)
		stackString = stackString + This.GetStack(.T.)
		Messagebox(stackString, 0, _Screen.Caption)
		If Sys(2410) <> "1"
			Quit
			Return To Master
		Endif
	Endproc

	Procedure GetStack
		Lparameters backTwo
		Local stackString, stackArray[1], stackLength, stackLoop
		stackLength = Astackinfo(stackArray)
		stackLength = stackLength - Iif(Empty(backTwo), 1, 2)
		stackString = ""
		For stackLoop = stackLength To 1 Step -1
			stackString = stackString + Transform(stackArray[stackLoop, 3]) ;
				+ "-" + Transform(stackArray[stackLoop, 5]) + Chr(13)
		Next
		Return stackString
	Endfunc

	Procedure Init
		_Screen.Newobject("dpisystem","dpisystem","dpiaware.vcx")
		This.CreateMenu()
	Endproc

	Procedure ReadEvents
		On Shutdown Clear Events
		Read Events
		On Shutdown
	Endproc

	Procedure CreateMenu
		Set Sysmenu To
		Define Pad Examples Of _Msysmenu Prompt "Examples"
		On Pad Examples Of _Msysmenu Activate Popup Examples

		Define Popup Examples Margin Relative
		On Selection Popup Examples goMainApplication.Examples(Bar())

		Define Bar 1 Of Examples Prompt "Common Controls"
		Define Bar 2 Of Examples Prompt "ActiveX Control"
	DEFINE BAR 3 OF Examples PROMPT "SysMetric Values"
	DEFINE BAR 4 OF Examples PROMPT "\-"
	DEFINE BAR 5 OF Examples PROMPT "Exit"
ENDPROC 

PROCEDURE Examples
	LPARAMETERS tnBar
	DO CASE 
	CASE tnBar = 1
		DO FORM CommonControls
	CASE tnBar = 2
		DO FORM ActiveXControl
	CASE tnBar = 3
		This.DisplaySysMetricValues()
	CASE tnBar = 5
		CLEAR EVENTS 
	OTHERWISE 
		MESSAGEBOX("Not implemented")
	ENDCASE 
ENDPROC 

PROCEDURE DisplaySysMetricValues
	LOCAL msg
	msg = "SysMetric values for primary monitor: " ;
		+ TRANSFORM(SYSMETRIC(1)) + " x " + TRANSFORM(SYSMETRIC(2)) ;
		+ CHR(13) + "_Screen.DpiFactor: " + TRANSFORM(_Screen.DpiFactor) ;
		+ CHR(13) + "Vertical scroll bar arrow width: " + TRANSFORM(SYSMETRIC(5))
	MESSAGEBOX(msg, 0, _Screen.Caption)
ENDPROC 
ENDDEFINE 