use chrono::prelude::*;
use clap::Parser;
use std::fs;
use std::io::prelude::*;
use std::io::BufReader;
use std::path::PathBuf;
use std::process::Command;
use std::process::Stdio;

const REC_FILENAME: &'static str = "rec.flac";
const MIX_FILENAME: &'static str = "mix.flac";

/// Easily re-encode recordings
#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Args {
    /// Path to an .rre file
    input: PathBuf,
}

struct TrimInfo {
    folder: String,
    start: String,
    end: String,
    fadein: bool,
    fadeout: bool,
}

struct Audio {
    language: String,
    title: String,
}

struct Metadata {
    title: String,
    audio: Vec<Audio>,
    datetime: String,
    crf: u8,
    output: String,
}

fn main() {
    let args = Args::parse();
    let home = match std::env::var("HOME") {
        Ok(home) => home,
        Err(reason) => panic!("HOME environment variable not set: {reason}"),
    };

    let (reencode_info, metadata) = parse_input(&home, args.input);
    let record_directory = get_record_directory(&home);
    let cmd_args = generate_cmd_args(reencode_info, metadata, record_directory);
    let stdout = Command::new("ffmpeg")
        .args(cmd_args)
        .stdout(Stdio::piped())
        .spawn()
        .unwrap()
        .stdout
        .unwrap();
    let reader = BufReader::new(stdout);
    reader
        .lines()
        .for_each(|line| println!("{}", line.unwrap()));
}

fn parse_input(home: &String, input_path: PathBuf) -> (Vec<TrimInfo>, Metadata) {
    let mut input_reader = BufReader::new(fs::File::open(input_path).unwrap());
    let mut folder_name = String::new();
    let mut reencode_info: Vec<TrimInfo> = Vec::new();
    let mut metadata = Metadata {
        title: String::new(),
        audio: Vec::new(),
        datetime: Local::now().format("%Y-%m-%d %H:%M:%S").to_string(),
        crf: 42,
        output: String::new(),
    };
    loop {
        let mut line = String::new();
        match input_reader.read_line(&mut line) {
            Ok(0) => break, // End of file
            Ok(_) => {
                let content: &str = line.split('#').next().unwrap_or("").trim();
                if content.is_empty() {
                    continue;
                }
                match content.find('=') {
                    Some(byte_index) => parse_metadata(&mut metadata, content, byte_index, home),
                    None => parse_trim_info(&mut reencode_info, &mut folder_name, content),
                }
            }
            Err(reason) => panic!("Failed to read line: {reason}"),
        }
    }
    (reencode_info, metadata)
}

fn parse_metadata(metadata: &mut Metadata, content: &str, byte_index: usize, home: &String) {
    let key = &content[0..byte_index];
    let value = &content[byte_index + 1..];
    match key.to_ascii_lowercase().as_str() {
        "title" => {
            metadata.title = value.to_string();
        }
        "audio" => {
            // 3 char length language + space + title
            metadata.audio.push(Audio {
                language: String::from(&value[0..3]),
                title: String::from(&value[4..]),
            });
        }
        "datetime" => {
            metadata.datetime = value.to_string();
        }
        "crf" => {
            metadata.crf = value.parse().unwrap();
        }
        "output" => {
            let mut output = String::from(value);
            if value.chars().nth(0) == Some('~') {
                output = format!("{home}{}", &value[1..]);
            }
            metadata.output = output;
        }
        invalid_key => {
            eprintln!("Invalid key: {invalid_key}");
            panic!("Could not parse metadata");
        }
    }
}

fn parse_trim_info(reencode_info: &mut Vec<TrimInfo>, folder_name: &mut String, content: &str) {
    let tokens: Vec<String> = content.split_whitespace().map(|s| s.to_owned()).collect();
    match tokens.len() {
        0 => (), // Empty line, ignore
        1 => {
            // New folder specified
            folder_name.clear();
            folder_name.push_str(tokens[0].as_str());
        }
        2 => {
            // Start time, end time specified
            if folder_name.is_empty() {
                eprint!("Trim information found before folder name");
                panic!("Failed parsing input file");
            }
            reencode_info.push(TrimInfo {
                folder: folder_name.to_string(),
                start: tokens[0].to_string(),
                end: tokens[1].to_string(),
                fadein: false,
                fadeout: false,
            })
        }
        3 => {
            // Start time, end time and fade specified
            if folder_name.is_empty() {
                eprint!("Trim information found before folder name");
                panic!("Failed parsing input file");
            }
            let mut trim_info = TrimInfo {
                folder: folder_name.to_string(),
                start: tokens[0].to_string(),
                end: tokens[1].to_string(),
                fadein: false,
                fadeout: false,
            };
            match tokens[2].as_str() {
                "fade-in" => trim_info.fadein = true,
                "fade-out" => trim_info.fadeout = true,
                "fade-in-out" => {
                    trim_info.fadein = true;
                    trim_info.fadeout = true;
                }
                text => {
                    eprintln!(
                        "Expected fade-in, fade-out or fade-in-out, found {text}.\n{content}"
                    );
                    panic!("Failed parsing input file");
                }
            }
            reencode_info.push(trim_info);
        }
        count => {
            eprintln!("Expected up to 3 tokens, found {count}.\n{content}");
            panic!("Failed parsing input file");
        }
    }
}

fn get_record_directory(home: &String) -> PathBuf {
    let record_directory = match fs::File::open(format!("{home}/.config/record/config")) {
        Ok(config_file) => {
            let mut config_reader = BufReader::new(config_file);
            loop {
                let mut line = String::new();
                match config_reader.read_line(&mut line) {
                    Ok(0) => {
                        eprintln!("Record directory setting not found. Default to {home}/Videos");
                        break format!("{home}/Videos");
                    }
                    Ok(_) => {
                        let key_value: Vec<&str> = line.split('=').collect();
                        if key_value[0] == "directory" {
                            break key_value[1].trim().to_string();
                        }
                    }
                    Err(reason) => {
                        eprintln!("Error while reading configuration file: {reason}");
                        break format!("{home}/Videos");
                    }
                }
            }
        }
        Err(_) => {
            eprintln!("Configuration file not found. Default to {home}/Videos");
            format!("{home}/Videos")
        }
    };
    PathBuf::from(record_directory)
}

fn generate_cmd_args(
    reencode_info: Vec<TrimInfo>,
    metadata: Metadata,
    record_directory: PathBuf,
) -> Vec<String> {
    let mut target_directory = record_directory.clone();
    let (has_rec, has_mix) = {
        let mut has_rec = false;
        let mut has_mix = false;
        target_directory.push(reencode_info[0].folder.clone());
        for entry in target_directory.read_dir().unwrap() {
            match entry.unwrap().file_name().into_string().unwrap().as_str() {
                REC_FILENAME => has_rec = true,
                MIX_FILENAME => has_mix = true,
                _ => (),
            }
        }
        (has_rec, has_mix)
    };

    // Create ffmpeg command with inputs, prepare filter complex
    let mut cmd_args: Vec<String> = vec![String::from("-nostdin")];
    let mut filter_args: Vec<String> = Vec::new();
    let mut concat_filter = String::new();
    let mut stream_index = 0;
    for trim_info in &reencode_info {
        target_directory = record_directory.clone();
        target_directory.push(trim_info.folder.clone());
        cmd_args.append(&mut generate_input_args(
            trim_info,
            &target_directory,
            has_rec,
            has_mix,
        ));
        filter_args.append(&mut generate_filter_complex(
            &mut concat_filter,
            &mut stream_index,
            trim_info,
            has_rec,
            has_mix,
        ));
    }

    // Finish generating filter complex
    let mut map_args = finish_concat_filter(
        &mut concat_filter,
        has_rec,
        has_mix,
        stream_index,
        reencode_info.len(),
    );
    filter_args.push(concat_filter);

    // Add filter complex and map args to cmd_args
    cmd_args.push(String::from("-filter_complex"));
    cmd_args.push(filter_args.join(";"));
    cmd_args.append(&mut map_args);

    // Metadata and codecs
    cmd_args.append(&mut generate_metadata_args(&metadata));
    cmd_args.append(&mut generate_codec_args(metadata.output, metadata.crf));

    cmd_args
}

fn generate_input_args(
    trim_info: &TrimInfo,
    target_directory: &PathBuf,
    has_rec: bool,
    has_mix: bool,
) -> Vec<String> {
    let mut input_args: Vec<String> = Vec::new();
    let base_input_args = vec![
        String::from("-ss"),
        trim_info.start.clone(),
        String::from("-to"),
        trim_info.end.clone(),
        String::from("-i"),
    ];

    // Video
    let mut video_input = target_directory.clone();
    video_input.push("video.mp4");
    let mut video_args = base_input_args.clone();
    video_args.push(String::from(video_input.to_str().unwrap()));
    input_args.append(&mut video_args);

    // Recording audio stream
    if has_rec {
        let mut rec_input = target_directory.clone();
        rec_input.push(REC_FILENAME);
        let mut rec_args = base_input_args.clone();
        rec_args.push(String::from(rec_input.to_str().unwrap()));
        input_args.append(&mut rec_args);
    }

    // Mix audio stream
    if has_mix {
        let mut mix_input = target_directory.clone();
        mix_input.push(MIX_FILENAME);
        let mut mix_args = base_input_args.clone();
        mix_args.push(String::from(mix_input.to_str().unwrap()));
        input_args.append(&mut mix_args);
    }
    input_args
}

fn generate_filter_complex(
    concat_filter: &mut String,
    stream_index: &mut usize,
    trim_info: &TrimInfo,
    has_rec: bool,
    has_mix: bool,
) -> Vec<String> {
    let mut filter_args: Vec<String> = Vec::new();

    // Video
    let mut filters: Vec<String> = Vec::new();
    if trim_info.fadein {
        filters.push(String::from("fade=in:st=0:d=0.15"));
    }
    if trim_info.fadeout {
        filters.push(format!(
            "fade=out:st={:.3}:d=0.15",
            time_to_secs(trim_info.end.clone()) - time_to_secs(trim_info.start.clone()) - 0.15
        ));
    }
    if filters.is_empty() {
        concat_filter.push_str(&format!("[{stream_index}:v]"));
    } else {
        let before_stream_name = format!("[{stream_index}:v]");
        let after_stream_name = format!("[{stream_index}v]");
        filter_args.push(format!(
            "{before_stream_name}{}{after_stream_name}",
            filters.join(",")
        ));
        concat_filter.push_str(&after_stream_name);
    }
    *stream_index += 1;

    // Recording audio stream
    if has_rec {
        concat_filter.push_str(&format!("[{stream_index}:a]"));
        *stream_index += 1;
    }

    // Mix audio stream
    if has_mix {
        concat_filter.push_str(&format!("[{stream_index}:a]"));
        *stream_index += 1;
    }
    filter_args
}

fn finish_concat_filter(
    concat_filter: &mut String,
    has_rec: bool,
    has_mix: bool,
    stream_count: usize,
    trim_count: usize,
) -> Vec<String> {
    concat_filter.push_str(&format!(
        "concat=n={}:v=1:a={}[outv]",
        trim_count,
        stream_count / trim_count - 1
    ));
    let mut map_args = vec![String::from("-map"), String::from("[outv]")];
    if has_rec {
        concat_filter.push_str("[outr]");
        let mut rec_map_args = vec![String::from("-map"), String::from("[outr]")];
        map_args.append(&mut rec_map_args);
    }
    if has_mix {
        concat_filter.push_str("[outm]");
        let mut mix_map_args = vec![String::from("-map"), String::from("[outm]")];
        map_args.append(&mut mix_map_args);
    }
    map_args
}

fn generate_metadata_args(metadata: &Metadata) -> Vec<String> {
    let mut metadata_args: Vec<String> = Vec::new();

    // Title
    if !metadata.title.is_empty() {
        metadata_args.push(String::from("-metadata:g"));
        metadata_args.push(format!("title={}", metadata.title));
    }

    // Creation time
    metadata_args.push(String::from("-metadata:g"));
    metadata_args.push(format!("creation_time={}", metadata.datetime));

    // Stream language & title
    for (stream_index, stream) in metadata.audio.iter().enumerate() {
        let arg_key = format!("-metadata:s:{}", stream_index + 1);
        metadata_args.push(arg_key.clone());
        metadata_args.push(format!("language={}", stream.language));
        metadata_args.push(arg_key);
        metadata_args.push(format!("title={}", stream.title));
    }
    metadata_args
}

fn generate_codec_args(output_path: String, crf: u8) -> Vec<String> {
    let mut codec_args: Vec<String> = Vec::new();
    if output_path.is_empty() {
        println!("Output path is not set. Generate test output at /tmp/test.mkv");
        let mut codecs_args = vec![
            String::from("-vcodec"),
            String::from("libsvtav1"),
            String::from("-r"),
            String::from("30"),
            String::from("-crf"),
            format!("{}", crf),
            String::from("-preset"),
            String::from("13"),
            String::from("-g"),
            String::from("600"),
            String::from("-pix_fmt"),
            String::from("yuv420p"),
            String::from("-acodec"),
            String::from("libopus"),
        ];
        codec_args.append(&mut codecs_args);

        codec_args.push(String::from("-y"));
        codec_args.push(String::from("/tmp/test.mkv"));
    } else {
        let mut codecs_args = vec![
            String::from("-vcodec"),
            String::from("libsvtav1"),
            String::from("-r"),
            String::from("60"),
            String::from("-crf"),
            format!("{}", crf),
            String::from("-preset"),
            String::from("0"),
            String::from("-g"),
            String::from("600"),
            String::from("-pix_fmt"),
            String::from("yuv420p"),
            String::from("-acodec"),
            String::from("libopus"),
        ];
        codec_args.append(&mut codecs_args);

        codec_args.push(output_path);
    }
    codec_args
}

fn time_to_secs(time: String) -> f64 {
    time.split(':')
        .rev()
        .map(|value| match value.parse::<f64>() {
            Ok(value) => value,
            Err(reason) => {
                eprintln!("Cannot convert {value} to float: {reason}");
                panic!("Failed parsing time");
            }
        })
        .enumerate()
        .fold(0.0, |acc, x| acc + x.1 * (60f64).powi(x.0 as i32))
}
