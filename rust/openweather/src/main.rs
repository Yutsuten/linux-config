use std::env;
use std::fs;
use std::io::prelude::*;
use std::time::SystemTime;
use serde_json::Value;

const OPENWEATHER_API_URL: &'static str = "https://api.openweathermap.org/data/2.5/weather";
const CACHE_FILE_DIR: &'static str = "/tmp/openweather";
const CACHE_TIMEOUT: u64 = 900;

fn fetch_weather_data() -> Value {
    let key = env::var("OPEN_WEATHER_KEY").unwrap();
    let lat = env::var("OPEN_WEATHER_LAT").unwrap();
    let lon = env::var("OPEN_WEATHER_LON").unwrap();

    let url = format!("{api_url}?appid={key}&lat={lat}&lon={lon}&units=metric", api_url=OPENWEATHER_API_URL);
    let response = reqwest::blocking::get(url).unwrap();
    if !response.status().is_success() {
        panic!("Failed to fetch weather data");
    }

    let raw_json = response.text().unwrap();
    let mut cache_file = fs::File::create(CACHE_FILE_DIR).unwrap();
    cache_file.write_all(raw_json.as_bytes()).unwrap();

    return serde_json::from_str(&raw_json).unwrap();
}

fn main() {
    let json_data: Value = match fs::File::open(CACHE_FILE_DIR) {
        Ok(file) => {
            let cache_timestamp = fs::metadata(CACHE_FILE_DIR).unwrap().modified().unwrap().duration_since(SystemTime::UNIX_EPOCH).unwrap().as_secs();
            let now_timestamp = SystemTime::now().duration_since(SystemTime::UNIX_EPOCH).unwrap().as_secs();

            if now_timestamp > cache_timestamp + CACHE_TIMEOUT {
                fetch_weather_data()
            } else {
                serde_json::from_reader(&file).unwrap()
            }
        },
        Err(_) => fetch_weather_data(),
    };

    // https://openweathermap.org/weather-conditions
    let icon = match json_data["weather"][0]["icon"].as_str().unwrap() {
        "01d" =>  "☀️", "01n" =>  "🌙",
        "02d" =>  "⛅️", "02n" =>  "🌙",
        "03d" =>  "☁️", "03n" =>  "☁️",
        "04d" =>  "☁️", "04n" =>  "☁️",
        "09d" =>  "🌧️", "09n" =>  "🌧️",
        "10d" =>  "🌦️", "10n" =>  "",
        "11d" =>  "⛈️", "11n" =>  "⛈️",
        "13d" =>  "❄️", "13n" =>  "❄️",
        "50d" =>  "", "50n" =>  "",
        icon => icon,
    };
    let tooltip1 = [
        format!("💧 {humidity}%", humidity=&json_data["main"]["humidity"]),
        format!("🎏 {wind_speed:.0}km/h", wind_speed=json_data["wind"]["speed"].as_f64().unwrap() * 3.6),
        format!("☁️ {clouds}%", clouds=&json_data["clouds"]["all"]),
    ];

    let mut tooltip2 = Vec::new();
    if json_data["snow"]["1h"].is_f64() {
        tooltip2.push(format!("☃️ {snow}mm (1h)", snow=json_data["snow"]["1h"]));
    }
    if json_data["rain"]["1h"].is_f64() {
        tooltip2.push(format!("☔ {rain}mm (1h)", rain=json_data["rain"]["1h"]));
    }

    let output = serde_json::json!({
        "text": format!("{icon} {temperature:.0}°C", temperature=json_data["main"]["temp"].as_f64().unwrap()),
        "tooltip": if tooltip2.len() > 0 {
            format!("{}\r{}", tooltip1.join("　"), tooltip2.join("　"))
        } else {
            tooltip1.join("　")
        },
    });
    println!("{}", serde_json::to_string(&output).unwrap());
}
