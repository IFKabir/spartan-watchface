import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SpartanFaceView extends WatchUi.WatchFace {

    // Variable to hold our smaller custom font
    private var _sevenSegmentFontSmall;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Load the new SMALLER custom font from your resources
        _sevenSegmentFontSmall = WatchUi.loadResource(Rez.Fonts.SevenSegmentFontSmall);
    }

    function onShow() as Void {
    }

    function onHide() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        // Clear the screen to black
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Get the current time
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;

        // Check user device settings for 12/24 hour format
        if (!System.getDeviceSettings().is24Hour) {
            hours = hours % 12;
            if (hours == 0) { 
                hours = 12; 
            }
        }

        // Format the time string (e.g., "10:09")
        var timeString = Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);

        // Draw the time perfectly centered using the smaller font
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2, 
            dc.getHeight() / 2, 
            _sevenSegmentFontSmall, // <-- Now using the small version
            timeString, 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function onEnterSleep() as Void {
    }

    function onExitSleep() as Void {
    }
}