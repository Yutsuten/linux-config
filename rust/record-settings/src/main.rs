use iced::widget::{column, row, scrollable, Button, Checkbox, Text, TextInput};
use iced::Element;
use iced::Task;
use std::fmt;
use std::fs;
use std::io::prelude::*;

const CONFIG: &'static str = "config";

#[derive(Debug, Clone)]
enum Message {
    Directory(String),
    Name(String),
    AudioSpeakers(bool),
    AudioMic(bool),
    AudioRecording(bool),
    Save,
}

struct Config {
    directory: String,
    name: String,
    audio_speakers: bool,
    audio_mic: bool,
    audio_recording: bool,
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
        writeln!(f, "name={}", self.name)?;
        writeln!(f, "audio-speakers={}", self.audio_speakers)?;
        writeln!(f, "audio-mic={}", self.audio_mic)?;
        writeln!(f, "audio-recording={}", self.audio_recording)
    }
}

impl Default for Config {
    fn default() -> Self {
        let home = std::env::var("HOME").unwrap();

        // Default values
        let mut config = Self {
            directory: format!("{home}/Videos"),
            name: String::new(),
            audio_speakers: true,
            audio_mic: true,
            audio_recording: true,
            save_dir: format!("{home}/.config/record"),
        };

        // Try to read configuration
        let mut file = match fs::File::open(format!("{}/{CONFIG}", &config.save_dir)) {
            Ok(file) => file,
            Err(_) => {
                return config;
            }
        };
        let mut file_contents = String::new();
        file.read_to_string(&mut file_contents).unwrap();
        for line in file_contents.lines() {
            let key_value: Vec<&str> = line.split('=').collect();
            match key_value[0] {
                "directory" => config.directory = key_value[1].to_string(),
                "name" => config.name = key_value[1].to_string(),
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
    fn view(&self) -> Element<'_, Message> {
        scrollable(
            column![
                row![
                    Text::new("Directory"),
                    TextInput::new("/mnt/hdd/Recording", &self.directory)
                        .on_input(Message::Directory)
                ]
                .spacing(10),
                row![
                    Text::new("Name (optional)"),
                    TextInput::new("", &self.name).on_input(Message::Name)
                ]
                .spacing(10),
                Checkbox::new("Recording", self.audio_recording).on_toggle(Message::AudioRecording),
                Checkbox::new("Speakers", self.audio_speakers).on_toggle(Message::AudioSpeakers),
                Checkbox::new("Mic", self.audio_mic).on_toggle(Message::AudioMic),
                Button::new("Save & Exit").on_press(Message::Save),
            ]
            .padding(20)
            .spacing(10),
        )
        .into()
    }

    fn update(&mut self, message: Message) -> Task<Message> {
        match message {
            Message::Directory(text) => {
                self.directory = text;
                Task::none()
            }
            Message::Name(text) => {
                self.name = text;
                Task::none()
            }
            Message::AudioSpeakers(checked) => {
                self.audio_speakers = checked;
                Task::none()
            }
            Message::AudioMic(checked) => {
                self.audio_mic = checked;
                Task::none()
            }
            Message::AudioRecording(checked) => {
                self.audio_recording = checked;
                Task::none()
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
                iced::exit()
            }
        }
    }
}
