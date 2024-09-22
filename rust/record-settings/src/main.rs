use iced::widget::{column, row, Button, Checkbox, Column, Text, TextInput};
use std::fmt;
use std::fs;
use std::io::prelude::*;

const CONFIG: &'static str = "config";

#[derive(Debug, Clone)]
enum Message {
    Directory(String),
    Waybar(bool),
    AudioSpeakers(bool),
    AudioMic(bool),
    AudioRecording(bool),
    Save,
}

struct Config {
    directory: String,
    waybar: bool,
    audio_speakers: bool,
    audio_mic: bool,
    audio_recording: bool,
    changed: bool,
    save_dir: String,
}

pub fn main() -> iced::Result {
    iced::application("Record Settings", Config::update, Config::view)
        .theme(theme)
        .run()
}

fn theme(_state: &Config) -> iced::Theme {
    iced::Theme::Dark
}

impl fmt::Display for Config {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        writeln!(f, "directory={}", self.directory)?;
        writeln!(f, "waybar={}", self.waybar)?;
        writeln!(f, "audio-speakers={}", self.audio_speakers)?;
        writeln!(f, "audio-mic={}", self.audio_mic)?;
        writeln!(f, "audio-recording={}", self.audio_recording)
    }
}

impl Default for Config {
    fn default() -> Self {
        // Default values
        let mut config = Self {
            directory: String::from("/mnt/hdd/Recording"),
            waybar: true,
            audio_speakers: true,
            audio_mic: true,
            audio_recording: true,
            changed: false,
            save_dir: std::env::var("HOME").unwrap() + "/.config/record",
        };

        // Try to read configuration
        let mut file = match fs::File::open(format!("{}/{CONFIG}", &config.save_dir)) {
            Ok(file) => file,
            Err(_) => {
                config.changed = true;
                return config;
            }
        };
        let mut file_contents = String::new();
        file.read_to_string(&mut file_contents).unwrap();
        for line in file_contents.lines() {
            let key_value: Vec<&str> = line.split('=').collect();
            match key_value[0] {
                "directory" => config.directory = key_value[1].to_string(),
                "waybar" => config.waybar = key_value[1] == "true",
                "audio-speakers" => config.audio_speakers = key_value[1] == "true",
                "audio-mic" => config.audio_mic = key_value[1] == "true",
                "audio-recording" => config.audio_recording = key_value[1] == "true",
                invalid_key => eprintln!("Invalid key ignored: {}", invalid_key),
            }
        }
        config
    }
}

impl Config {
    fn view(&self) -> Column<Message> {
        column![
            row![
                Text::new("Directory"),
                TextInput::new("/mnt/hdd/Recording", &self.directory).on_input(Message::Directory)
            ]
            .spacing(10),
            Checkbox::new("Waybar", self.waybar).on_toggle(Message::Waybar),
            Checkbox::new("Audio Speakers", self.audio_speakers).on_toggle(Message::AudioSpeakers),
            Checkbox::new("Audio Mic", self.audio_mic).on_toggle(Message::AudioMic),
            Checkbox::new("Audio Recording", self.audio_recording)
                .on_toggle(Message::AudioRecording),
            match self.changed {
                true => Button::new("Save").on_press(Message::Save),
                false => Button::new("Save"),
            }
        ]
        .padding(20)
        .spacing(10)
        .into()
    }

    fn update(&mut self, message: Message) {
        match message {
            Message::Directory(text) => {
                self.directory = text;
                self.changed = true;
            }
            Message::Waybar(checked) => {
                self.waybar = checked;
                self.changed = true;
            }
            Message::AudioSpeakers(checked) => {
                self.audio_speakers = checked;
                self.changed = true;
            }
            Message::AudioMic(checked) => {
                self.audio_mic = checked;
                self.changed = true;
            }
            Message::AudioRecording(checked) => {
                self.audio_recording = checked;
                self.changed = true;
            }
            Message::Save => {
                match fs::exists(&self.save_dir) {
                    Ok(true) => (),
                    Ok(false) => {
                        fs::create_dir_all(&self.save_dir).unwrap();
                    }
                    Err(_) => panic!(
                        "Unable to access configuration directory: {}",
                        &self.save_dir
                    ),
                };
                write!(
                    fs::File::create(format!("{}/{CONFIG}", &self.save_dir)).unwrap(),
                    "{}",
                    &self
                )
                .unwrap();
                self.changed = false;
            }
        }
    }
}
