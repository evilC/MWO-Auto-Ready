MWO-Auto-Ready
==============

A Script for MWO that automatically clicks ready for you

Example Usage:
Take the ready.exe from the zip and place it somewhere. It creates an INI file in the same folder, so best not to put it on the desktop.

Double-click ready.exe to run it.

STEP 1: BIND HOTKEYS
====================
Go to the Bindings tab.

Tick "Program Mode"

Tick "Limit to Application: ..."

On the "Calibrate" row:
Click the box in the "Keyboard" column and hit the C key.
Tick the Ctrl and Alt boxes.

On the "Auto Ready" row:
Click the box in the "Keyboard" column and hit the R key.
Tick the Ctrl and Alt boxes.

Untick "Program Mode"

STEP 2: CALIBRATE
=================
On the main tab, make sure "Status" is Off.
(It will probably be disabled)

Launch an MWO match.

Place the cursor over the Ready button.

Hit CTRL+ALT+C

The match should start as normal.

When you return to mechlab, the boxes on the main tab should be filled out, and the Status box enabled.


Step 3: NORMAL USAGE
====================
Make sure the Status dropdown on the Main tab is set to "On".

Start a game. The app should automatically detect the transition from mechlab to game (Window size gets bigger) and auto-trigger.

If it does not, or it does and you do not want it to, you can manually turn it on or off with CTRL+ALT+R


OPTIONAL SCREEN RECORDING START
===============================
This feature will automatically start your Screen Capture software after readying up.
It will hit ALT+F9 (Default for nVidia ShadowPlay) after a pre-determined delay (Default 20 secs)

If using ShadowPlay, you would need to set recording mode to "Manual".
As of time of writing, the ShadowPlay beta is limited to 4GB file sizes (Roughly 10 mins at high quality).
If you wish to capture a full match, you may need to set Quality to "Medium".

ADVANCED
=========
For optimal usage, you may want to position the mouse over the white of the word "Ready" when you calibrate.
This should result in the app being able to reliably detect a good ready when the text changes colour.

The ready.ahk file is the source code.
In most cases you should not need it, but if you do you will also need a copy of ADHD from http://evilc.com/proj/adhd

The "Play Debug Beeps" option is to help debugging what is going on if it does not work.
The "Debug Mode" and "Show Window" options in the top right of the window would also help here.


