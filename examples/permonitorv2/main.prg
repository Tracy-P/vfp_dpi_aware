*-- Vista popup menu artifact fix
IF OS(3) = "6"
   DECLARE integer GdiSetBatchLimit IN WIN32API integer
   GdiSetBatchLimit(1)
ENDIF

*-- Initial size of app
_VFP.Width = SYSMETRIC(1) * .5
_VFP.Height = SYSMETRIC(2) * .75
_VFP.Left = 0
_VFP.Top = 0

PRIVATE goMainApplication
goMainApplication = CREATEOBJECT("MainApplicationClass")
goMainApplication.ReadEvents()
ON SHUTDOWN 



DEFINE CLASS MainApplicationClass as Custom 

PROCEDURE Error
	LPARAMETERS errorNumber, methodName, lineNumber
	LOCAL stackString
	stackString = "Error: " + TRANSFORM(errorNumber) + " " + TRANSFORM(MESSAGE()) + CHR(13)
	stackString = stackString + This.GetStack(.T.)
	MESSAGEBOX(stackString, 0, _Screen.Caption)
	IF SYS(2410) <> "1"
		QUIT 
		RETURN TO MASTER 
	ENDIF
ENDPROC 

PROCEDURE GetStack
	LPARAMETERS backTwo
	LOCAL stackString, stackArray[1], stackLength, stackLoop
	stackLength = ASTACKINFO(stackArray)
	stackLength = stackLength - IIF(EMPTY(backTwo), 1, 2)
	stackString = ""
	FOR stackLoop = stackLength TO 1 STEP -1
		stackString = stackString + TRANSFORM(stackArray[stackLoop, 3]) ;
			+ "-" + TRANSFORM(stackArray[stackLoop, 5]) + CHR(13)
	NEXT 
	RETURN stackString
ENDFUNC 

PROCEDURE Init
	_Screen.NewObject("dpiwatch","dpiwatch","dpiaware.vcx")
	This.CreateMenu()
	*BINDEVENT(_Screen.DpiWatch, "DpiChanged", This, "CreateMenu", 1)
ENDPROC 

PROCEDURE ReadEvents
	ON SHUTDOWN clear events
	READ EVENTS
	ON SHUTDOWN 
ENDPROC 

PROCEDURE CreateMenu
	SET SYSMENU TO 
	DEFINE PAD Examples OF _MSysMenu PROMPT "Examples" FONT "Segoe UI", 10 * _Screen.DpiFactor
	ON PAD Examples OF _MSysMenu ACTIVATE POPUP Examples

	DEFINE POPUP Examples MARGIN RELATIVE 
	ON SELECTION POPUP Examples goMainApplication.Examples(BAR())
	
	DEFINE BAR 1 OF Examples PROMPT "Common Controls" FONT "Segoe UI", 10 * _Screen.DpiFactor
	DEFINE BAR 2 OF Examples PROMPT "ActiveX Control" FONT "Segoe UI", 10 * _Screen.DpiFactor
	DEFINE BAR 3 OF Examples PROMPT "SysMetric Values" FONT "Segoe UI", 10 * _Screen.DpiFactor
	DEFINE BAR 4 OF Examples PROMPT "\-"
	DEFINE BAR 5 OF Examples PROMPT "Exit" FONT "Segoe UI", 10 * _Screen.DpiFactor
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
