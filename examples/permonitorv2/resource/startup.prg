*-- Vista popup menu artifact fix
If Os(3) = "6"
	Declare Integer GdiSetBatchLimit In WIN32API Integer
	GdiSetBatchLimit(1)
Endif

_vfp.Caption = _vfp.Caption + " (VFP Version: " + Version(4) + ")"

LoadMenu()

Procedure LoadMenu
	Local toolIsIn
	toolIsIn = Strextract(Sys(16), Program(Program(-1)))
	Define Pad Developer Of _Msysmenu Prompt "Developer"

	Define Popup Developer Margin Relative
	Define Bar 1 Of Developer Prompt "Modify Project"
	Define Bar 3 Of Developer Prompt "Build"
	Define Bar 99 Of Developer Prompt "\-"
	Define Bar 6 Of Developer Prompt "Start Code"
	Define Bar 98 Of Developer Prompt "\-"
	Define Bar 2 Of Developer Prompt "Reset Windows"
	Define Bar 4 Of Developer Prompt "Reset Toolbars"
	Define Bar 5 Of Developer Prompt "Clear Screen"

	On Pad Developer Of _Msysmenu Activate Popup Developer
	On Selection Popup Developer Do ProcessMenuSelection In &toolIsIn.

Endproc

Procedure ProcessMenuSelection
	Local selectedBar, toolIsIn

	Set Message To
	selectedBar = Bar()
	toolIsIn = Strextract(Sys(16), Program(Program(-1)))

	Do Case
	Case selectedBar = 1
		Do ModifyProject In &toolIsIn.
	Case selectedBar = 2
		Do ResetWindows In &toolIsIn.
	Case selectedBar = 3
		Do BuildExe In &toolIsIn.
	Case selectedBar = 4
		Do ResetToolbars In &toolIsIn.
	Case selectedBar = 5
		Activate Screen
		Clear
	Case selectedBar = 6
		Do RunCode In &toolIsIn.
	Otherwise
		Messagebox("Not Implemented", 0, "Developer Menu", 3000)
	Endcase
	Set Message To
Endproc

Procedure ClearScreen
	Activate Screen
	Clear
Endproc

Procedure ModifyProject
	If Wexist("Project Manager - Exampleapp")
		Activate Window ("Project Manager - Exampleapp")
		Return
	Endif
	Modify Project "exampleapp" Nowait
Endproc

Procedure RunCode
	Local oShell As WScript.Shell
	oShell = CREATEOBJECT("WScript.Shell")
	oShell.Exec(_vfp.ServerName + ' -t -c"' + Addbs(Sys(5) + Sys(2003)) + 'resource\code.fpw"')
	oShell = .Null.
Endproc

Procedure ResetWindows
	Private plToolBox, plTipWindow, pcCommandPosition, pnCommandDivisor
	plToolBox = .F.
	pcCommandPosition = [3 Window "Document"]
	pnCommandDivisor = 2

	*-- Make sure the windows are open
	Activate Window "View"
	Activate Window "Properties"
	Activate Window "Command"
	Activate Window "Document"

	*-- To get the windows back to proper size
	*-- they need to be undocked
	Dock Window "View"         POSITION -1
	Dock Window "Properties"   POSITION -1
	Dock Window "Command"      POSITION -1
	Dock Window "Document"     POSITION -1

	*-- To make things quick, close the toolbox
	If plToolBox
		If Type("_oToolBox") = "O" And Not Isnull(_oToolBox)
			_oToolBox.Release()
			Release _oToolBox
		Endif
	Endif

	*-- Set the sizes needed for the windows
	*-- The View (Data Session) window doesn't display well lower
	*-- than 52 cols wide.
	*-- Save the current Font settings of _Screen
	lcFontName = _Screen.FontName
	lnFontSize = _Screen.FontSize
	*-- Set them to the top window
	_Screen.FontName = Wfont(1,"Command")
	_Screen.FontSize = Wfont(2,"Command")
	Size Window "Command" To Srows()/pnCommandDivisor, Scols()/5
	*-- Set them to the top window
	_Screen.FontName = Wfont(1,"View")
	_Screen.FontSize = Wfont(2,"View")
	Size Window "View"    To Srows()/1.25, Max(52,Scols()/5)
	*-- Set them to the top window
	_Screen.FontName = Wfont(1,"Document")
	_Screen.FontSize = Wfont(2,"Document")
	Size Window "Document"    To Srows()/1.25, Max(52,Scols()/5)
	*-- Reset the font settings.
	_Screen.FontName = lcFontName
	_Screen.FontSize = lnFontSize

	If plToolBox
		*-- Start the ToolBox
		Do (_ToolBox)
		If Val(Version(4)) = 9
			_oToolBox.Dockable = 1
		Endif
	Endif

	*-- Now lets do some docking
	Dock Window "View"         POSITION 2
	Dock Window "Document"     POSITION 3 Window "View"
	Local lcPropPosition, lcDock
	lcPropPosition = [4 Window "View"]
	If plToolBox
		Dock Name _oToolBox POSITION &lcPropPosition.
	Endif
	Dock Window "Properties"   POSITION &lcPropPosition
	Dock Window "Command" POSITION &pcCommandPosition

	If plToolBox And Val(Version(4)) = 9
		*-- Put the Toolbox on top
		Activate Window (_oToolBox.Name)
	Endif
	*-- Make the Command window the last window active
	Activate Window "Command"
Endproc

Procedure BuildExe
	If Type("_vfp.ActiveProject.Name") == "C" And Lower(Juststem(_vfp.ActiveProject.Name)) = "exampleapp"
		If Not _vfp.ActiveProject.Build(Addbs(Justpath(_vfp.ActiveProject.Name)) + "bin\exampleapp.exe", 3, .F., .T., .F.)
			?Message()
		Endif
	Else
		?"Project not found to build"
	Endif
Endproc

Procedure ResetToolbars
	Private laToolbars[1]
	Local lnTop, lnLoop
	Dimension laToolbars[1]
	lnTop = 0
	For lnLoop = 1 To ToolbarNames()
		lnTop = MoveToolbar(laToolbars[lnLoop], lnTop)
	Next
Endproc

Procedure MoveToolbar
	Lparameters tcToolbar As Character, tnTop As Number
	*-- When the toolbar is not visible, exit
	If Not Wvisible(tcToolbar)
		Return tnTop
	Endif
	*-- Form Designer - Test.scx, is not the toolbar
	*-- Luckily, the toolbar seems to always come first
	If Upper(tcToolbar) <> Upper(Wtitle(tcToolbar))
		Return tnTop
	Endif
	Local lcFont, lnFont, lnLeft, lnConW, lnConH
	*-- Save Screen Font settings
	lcFont = _Screen.FontName
	lnFont = _Screen.FontSize
	*-- Set the screen font to the toolbars setting
	*-- This makes it easier to get sizes
	_Screen.FontName = Wfont(1,tcToolbar)
	_Screen.FontSize = Wfont(2,tcToolbar)
	*-- save some info for pixel to font conversion
	lnConW = 1 / Fontmetric(6)
	lnConH = 1 / Fontmetric(1)
	lnLeft = Scols() - Wcols(tcToolbar) - ((Sysmetric(3) * 2) * lnConW)
	*-- place the window
	Activate Window (tcToolbar) In Screen
	Move Window (tcToolbar) To tnTop, lnLeft
	*-- calculate the next top
	tnTop = tnTop + Wrows(tcToolbar) + ((Sysmetric(34) * lnConH)  + ((Sysmetric(4) * 2) * lnConH) )
	*-- reset the settings
	_Screen.FontName = lcFont
	_Screen.FontSize = lnFont
	Return tnTop
Endproc

Procedure ToolbarNames
	Dimension laToolbars[5]
	laToolbars[1] = "Form Designer"
	laToolbars[2] = "Form Controls"
	laToolbars[3] = "Report Designer"
	laToolbars[4] = "Report Controls"
	laToolbars[5] = "Layout"
	Return 5
Endproc
