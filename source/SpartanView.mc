import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class SpartanFaceView extends WatchUi.WatchFace {

    // Variable to hold our smaller custom font
    private var _sevenSegmentFontSmall;
    private var _dateNumberFont;
    private var _dateTextFont;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Load the new SMALLER custom font from your resources
        _sevenSegmentFontSmall = WatchUi.loadResource(Rez.Fonts.SevenSegmentFontSmall);
        _dateNumberFont = WatchUi.loadResource(Rez.Fonts.DateNumberFont);
        _dateTextFont = WatchUi.loadResource(Rez.Fonts.DateTextFont);
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

        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var dateY = dc.getHeight() * 0.25; // Place date at 25% from top

        // Get the date information
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayStr = dateInfo.day_of_week.toUpper();
        var monthStr = dateInfo.month.toUpper();
        var dateStr = dateInfo.day.format("%02d");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // --- DRAW DATE ---
        // 1. Draw the numeric date perfectly centered
        dc.drawText(
            centerX, 
            dateY, 
            _dateNumberFont, 
            dateStr, 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Calculate offset based on date width
        var dateWidth = dc.getTextWidthInPixels(dateStr, _dateNumberFont);
        var offset = (dateWidth / 2) + 8; // 8 pixels of padding between date and text

        // 2. Draw the day of week to the left
        dc.drawText(
            centerX - offset, 
            dateY, 
            _dateTextFont, 
            dayStr, 
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // 3. Draw the month to the right
        dc.drawText(
            centerX + offset, 
            dateY, 
            _dateTextFont, 
            monthStr, 
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // --- DRAW TIME ---
        // Draw the time perfectly centered using the smaller font
        dc.drawText(
            centerX, 
            centerY, 
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