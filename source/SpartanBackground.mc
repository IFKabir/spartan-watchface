import Toybox.Background;
import Toybox.System;
import Toybox.Communications;
import Toybox.Position;
import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;

(:background)
class SpartanBackground extends System.ServiceDelegate {

    function initialize() {
        System.ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        // Hardcoded API Key
        var apiKey = "32579bd88bd45bf2579903aa15742896";

        // Hardcoded Latitude and Longitude (Fallback to Lucknow, India)
        var lat = 26.8467;
        var lon = 80.9462;

        // Try to get actual GPS position if available
        var positionInfo = Position.getInfo();
        if (positionInfo != null && positionInfo.position != null) {
            var loc = positionInfo.position.toDegrees();
            lat = loc[0];
            lon = loc[1];
        }

        // Prepare the URL
        var url = "https://api.openweathermap.org/data/2.5/weather";

        // Prepare the parameters
        var params = {
            "lat" => lat.toFloat(),
            "lon" => lon.toFloat(),
            "appid" => apiKey,
            "units" => "metric"
        };

        // Prepare the options
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        // Make the web request
        Communications.makeWebRequest(url, params, options, method(:onReceive));
    }

    function onReceive(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 && data != null) {
            try {
                var main = data.get("main") as Dictionary;
                if (main != null) {
                    var temp = main.get("temp");
                    var humidity = main.get("humidity");
                    
                    if ((temp instanceof Number || temp instanceof Float) && (humidity instanceof Number || humidity instanceof Float)) {
                        var weatherData = {
                            "temp" => temp.toFloat(),
                            "humidity" => humidity.toNumber()
                        };
                        // Exit and send the data back to the main app
                        Background.exit(weatherData);
                        return;
                    }
                }
            } catch (e) {
                System.println("Error parsing OpenWeather JSON");
            }
        } else {
            System.println("OpenWeather request failed with code: " + responseCode);
        }
        
        // If we get here, something went wrong. Just exit with empty data.
        Background.exit({});
    }
}
