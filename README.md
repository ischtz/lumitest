## Description

This is a simple MATLAB script based on the Psychophysics Toolbox (www.psychtoolbox.org) to automate measuring monitor luminance curves using our USB-capable photometer (GOSSENS Mavo-Monitor USB). 

Licensed under the GPL; script provided as-is without any warranties as to result validity! Still, hopefully it might be useful in other labs. I'm happy for suggestions and/or functions to communicate with other photometers!

## Usage

Put the .m files into your MATLAB path (be sure that you have Psychtoolbox installed and working), then call as follows:

```
lumitest(<serial port device>)
```
with e.g. 'COM4' (Windows) or '/dev/ttyUSB0' (Linux) as the serial port device (default: 'COM4').
