import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Background;
import Toybox.System;
import Toybox.Time;

(:background)
class SpartanApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        // Register for background temporal events (every 5 minutes)
        if (System has :ServiceDelegate) {
            Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        }
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SpartanFaceView() ];
    }

    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    function getServiceDelegate() {
        return [new SpartanBackground()];
    }

    function onBackgroundData(data) {
        if (data != null && data instanceof Dictionary) {
            // Save weather data to storage
            Application.Storage.setValue("WeatherData", data);
            WatchUi.requestUpdate();
        }
    }
}

function getApp() as SpartanApp {
    return Application.getApp() as SpartanApp;
}