# VFP_DPI_AWARE
This project contains a library to assist legacy Visual FoxPro applications to be DPI Aware.
VFP applications are not natively DPI Aware and will be bitmap scaled when on a monitor that Windows scaling is different than 100% or different than the primary monitors scale factor.

Windows 10 has three ways that an application can be aware of scaling. 

- Unaware - The default for VFP applications
- System - The scale setting that is used is that of the primary monitor when the application is started.
- PerMonitor (Version 2) - The application will adjust to changes to the scale setting. This includes when moving the application to a monitor with a different scale setting.

This class library can be configured to work as System or PerMonitor. 

### <span style="color:darkred">**These are issues this class library cannot work around.**</span>

- The checkbox and optiongroup selection images do not grow when changing the font of these controls.
- The width of scrollbars, dropdown button of a combobox, and the spinners adjustments are based off the primary monitors scale setting when the application starts. 
- Adjusting the size and font of items within a Control class.

## Getting started
<span style="color:darkred">This project was initially at C:\work. The shortcuts in the Examples may need to adjusted</span>

This class library can be used to with either System or PerMonitor mode. PerMonitor mode will require Windows 10 Creator update at the minimum. 

Windows has two ways of making an application aware of scaling. One is with code after the application is started. This earliest VFP can call the API is too late to get the Menu to work correctly.  The other way is adding information to the manifest Windows applications look for. See the example projects to get a template for the manifest changes needed.

This repository is not configured to contain binary files. Please use the [FoxBin2Prg](https://github.com/fdbozzo/foxbin2prg) project to generate the binary files.

### Configuring for System

In the main program create the dpiSystem class as a private variable or attach it to the _Screen object. This configures the _Screen.dpiFactor property that the dpiresizer class will use.

```
private dpiSystem
m.dpiSystem = NEWOBJECT("dpiSystem", "dpiAware.vcx")
```
or
```
_SCREEN.NEWOBJECT("dpiSystem","dpiSystem","dpiAware.vcx")
```

### Configuring for PerMonitor

In the main program create the dpiWatch class as a private variable or attach it to the _Screen object.
This configures the _Screen.dpiFactor property that the dpiresizer class will use. It also configures a method to fire when a Windows Message is passed to the _VFP.HWnd. If your program already watches for Windows Messages, this will have some compatibility issues. See the `RegisterWatchForDpiChange` method.

### Configuring the Resizer

The intention of dpiResizer class is to be on the base form used in the application. This will allow overrides of controls that do not adjust well with these adjustments.

The call to resize the form can be done in the Init or the Activate only on the first activation of the screen.

```
THISFORM.dpiAware1.ResizeContainer(THISFORM)
```

If a object is added to the form (or a container on it), you can pass in the new object to the same method.

```
THISFORM.dpiAware1.ResizeContainer(THISFORM.NEWCONTROL)
```


