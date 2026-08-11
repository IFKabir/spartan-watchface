import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Activity;
import Toybox.UserProfile;

class SpartanFaceView extends WatchUi.WatchFace {

    // Variable to hold our smaller custom font
    private var _sevenSegmentFontSmall;
    private var _dateNumberFont;
    private var _dateTextFont;
    private var _weatherFont;

    private var _cachedRunDistanceStr = "--";
    private var _lastCacheTime = 0;

    function getWeeklyRunDistance() as String {
        var now = Time.now().value();
        if (now - _lastCacheTime > 300) { // Update every 5 minutes
            _lastCacheTime = now;
            _cachedRunDistanceStr = "0.0"; // Default
            
            if (Toybox has :UserProfile && Toybox.UserProfile has :getUserActivityHistory) {
                var history = Toybox.UserProfile.getUserActivityHistory();
                if (history != null) {
                    var totalDistanceMeters = 0.0;
                    // 7 days ago
                    var weekStart = Time.now().subtract(new Time.Duration(7 * 24 * 60 * 60));
                    
                    var entry = history.next();
                    while (entry != null) {
                        if (entry.startTime != null && entry.startTime.greaterThan(weekStart)) {
                            if (entry.type == Activity.SPORT_RUNNING && entry.distance != null) {
                                totalDistanceMeters += entry.distance;
                            }
                        }
                        entry = history.next();
                    }
                    var distanceKm = totalDistanceMeters / 1000.0;
                    _cachedRunDistanceStr = distanceKm.format("%.1f");
                }
            }
        }
        return _cachedRunDistanceStr;
    }

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Load the new SMALLER custom font from your resources
        _sevenSegmentFontSmall = WatchUi.loadResource(Rez.Fonts.SevenSegmentFontSmall);
        _dateNumberFont = WatchUi.loadResource(Rez.Fonts.DateNumberFont);
        _dateTextFont = WatchUi.loadResource(Rez.Fonts.DateTextFont);
        _weatherFont = WatchUi.loadResource(Rez.Fonts.WeatherFont);
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
        var dateY = (dc.getHeight() * 25) / 100; // Place date much higher (12% from top)

        // Get the date information
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayStr = dateInfo.day_of_week.toUpper();
        var monthStr = dateInfo.month.toUpper();
        var dateStr = dateInfo.day.format("%02d");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // --- DRAW WEATHER ---
        var weatherData = Application.Storage.getValue("WeatherData") as Dictionary?;
        if (weatherData != null) {
            var temp = weatherData.get("temp");
            var humidity = weatherData.get("humidity");
            if (temp instanceof Float && humidity instanceof Number) {
                var weatherY = (dc.getHeight() * 10) / 100;
                var weatherStr = temp.format("%.0f") + "C  " + humidity + "%";
                dc.drawText(
                    centerX, 
                    weatherY, 
                    _weatherFont, 
                    weatherStr, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );
            }
        }

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
        var offset = (dateWidth / 2) + 8; // Move them slightly further from the date (8 pixels padding)
        
        // Calculate Y position to align the bottom of the smaller text with the larger date
        var dateHeight = dc.getFontHeight(_dateNumberFont);
        var textHeight = dc.getFontHeight(_dateTextFont);
        var textY = dateY + (dateHeight - textHeight) / 2 + 4; // +4 visual baseline correction

        // 2. Draw the day of week to the left
        dc.drawText(
            centerX - offset, 
            textY, 
            _dateTextFont, 
            dayStr, 
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // 3. Draw the month to the right
        dc.drawText(
            centerX + offset, 
            textY, 
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

        // --- DRAW BATTERY ---
        var battery = System.getSystemStats().battery;
        var batteryY = (dc.getHeight() * 90) / 100;
        var batteryStr = battery.format("%.0f") + "%";
        dc.drawText(
            centerX, 
            batteryY, 
            _weatherFont, 
            batteryStr, 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // --- DRAW WEEKLY RUN DISTANCE ---
        var runStr = getWeeklyRunDistance();
        var runY = (dc.getHeight() * 75) / 100;
        var runX = (dc.getWidth() * 25) / 100;
        var titleHeight = dc.getFontHeight(_weatherFont);
        
        // Draw the title
        dc.drawText(
            runX, 
            runY - (titleHeight / 2), 
            _weatherFont, 
            "W.RUN KM:", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        // Draw the value right below it
        dc.drawText(
            runX, 
            runY + (titleHeight / 2), 
            _weatherFont, 
            runStr, 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function onEnterSleep() as Void {
    }

    function onExitSleep() as Void {
    }
}