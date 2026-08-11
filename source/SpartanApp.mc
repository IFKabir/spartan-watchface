import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

//! Main application class for the Spartan watch face.
//! Entry point defined in manifest.xml.
class SpartanApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    //! Return the initial (and only) view — the watch face.
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SpartanFaceView() ];
    }

    //! Called when the user changes settings in Garmin Connect Mobile.
    //! Triggers a UI refresh to apply new hand color, format, etc.
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }
}

function getApp() as SpartanApp {
    return Application.getApp() as SpartanApp;
}