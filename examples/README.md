# Examples
These three examples are the same application with a few differences. The application shows some basic windows to allow seeing how to use this class library in the different awareness modes available. 

The main difference between each of these is the manifest file in the folders. The next is the user of the dpiresizer class library. 

There is a **resource** folder that contains some startup code I use to work on these projects. The shortcuts may need to be adjusted for where you cloned this repository.

## UNAWARE
This is the standard VFP application as it is without being aware of Windows scaling. This does not use the dpiresizer class library. 

## SYSTEM
This is configured to be System Aware. It will work in Windows XP to Windows 10. As of this writing I have not tested it works in Windows 11.

The baseform class uses the dpiresizer class and the main application instantiates the dpisystem class.

## PERMONITOR V2
This is configured for Windows 10 Creators Update release and higher. It uses some Windows APIs that are not available in earlier versions. This will adjust the application when the scale factor changes. It can change when moving from screen to screen, or the user changes the monitors scale factor.

The baseform class uses the dpiresizer class and the main application instantiates the dpiwatch class.