use std::collections::HashSet;
use std::env;
use std::fs;
use std::io::BufReader;
use std::io::prelude::*;
use std::os::unix::fs::symlink;
use std::path::PathBuf;
use std::process;

use clap::Parser;
use rand::Rng;

const HIST_FILE: &'static str = "history";
const CUR_SYM: &'static str = "current";

/// Set wallpaper in sway
#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Args {
    /// Change to a random wallpaper
    #[arg(short, long, group = "group")]
    random: bool,

    /// Restore the last wallpaper used
    #[arg(short = 'e', long, group = "group")]
    restore: bool,

    /// Set an arbitrary wallpaper
    #[arg(short, long, group = "group", value_name = "FILE")]
    set: Option<PathBuf>,

    /// Unset a previously set arbitrary wallpaper
    #[arg(short, long, group = "group")]
    unset: bool,

    /// Print the current wallpaper path
    #[arg(short, long, group = "group")]
    current: bool,
}

fn main() {
    let args = Args::parse();
    let wallpapers_path = match env::var("WALLPAPERS_PATH") {
        Ok(value) => value,
        Err(reason) => panic!("WALLPAPERS_PATH environment variable not set: {reason}"),
    };
    let cache_path = format!("{}/.cache/wallpaper", env::var("HOME").unwrap());

    fs::create_dir_all(&cache_path).unwrap();

    if args.random {
        random_wallpaper(wallpapers_path, cache_path);
    } else if args.restore {
        match restore(&wallpapers_path, &cache_path, false) {
            Ok(_) => (),
            Err(reason) => {
                eprintln!("{reason}\nFallback to random wallpaper");
                random_wallpaper(wallpapers_path, cache_path)
            },
        };
    } else if let Some(set) = args.set {
        set_wallpaper(set.canonicalize().unwrap(), cache_path);
    } else if args.unset {
        match restore(&wallpapers_path, &cache_path, true) {
            Ok(_) => (),
            Err(reason) => {
                eprintln!("{reason}\nFallback to random wallpaper");
                random_wallpaper(wallpapers_path, cache_path)
            },
        };
    } else if args.current {
        current_wallpaper(wallpapers_path, cache_path);
    }
}

fn random_wallpaper(wallpapers_path: String, cache_path: String) {
    // Available wallpapers
    let available_wallpapers_set: HashSet<String> = HashSet::from_iter(
        fs::read_dir(&wallpapers_path).unwrap()
        .map(|res_entry| res_entry.unwrap().path())
        .filter(|path| path.is_file())
        .map(|path| path.file_name().unwrap().to_str().unwrap().to_owned())
    );
    if available_wallpapers_set.is_empty() {
        panic!("No wallpapers available");
    }

    // History wallpapers
    let hist_path = format!("{cache_path}/{HIST_FILE}");
    let mut hist_wallpapers_list: Vec<String> = match fs::File::open(&hist_path) {
        Ok(mut file) => {
            let mut history_file_contents = String::new();
            file.read_to_string(&mut history_file_contents).unwrap();
            history_file_contents.lines().map(|line| line.to_owned()).collect()
        },
        Err(_) => Vec::new(),
    };

    // Drop old history
    let max_hist_size = available_wallpapers_set.len() / 2;
    while hist_wallpapers_list.len() > max_hist_size {
        hist_wallpapers_list.pop();
    }

    // Randomly elect a new wallpaper
    let hist_wallpapers_set: HashSet<String> = HashSet::from_iter(hist_wallpapers_list.clone());
    let candidate_wallpapers: Vec<&String> = available_wallpapers_set.difference(&hist_wallpapers_set).collect();

    let mut rng = rand::thread_rng();
    let random_index = rng.gen_range(0..candidate_wallpapers.len());
    let elected_wallpaper = candidate_wallpapers[random_index];

    // Update and save history
    let mut hist_file = fs::File::create(hist_path).unwrap();
    writeln!(hist_file, "{}", elected_wallpaper).unwrap();
    write!(hist_file, "{}", hist_wallpapers_list.join("\n")).unwrap();

    // Apply elected wallpaper
    let elected_wallpaper_path = format!("{wallpapers_path}/{elected_wallpaper}");
    match apply_wallpaper(elected_wallpaper_path) {
        Ok(_) => (),
        Err(reason) => panic!("Failed to change wallpaper: {}", reason),
    };

    // Remove current (arbitrary) wallpaper symbolic link
    let cur_symlink = format!("{cache_path}/{CUR_SYM}");
    match fs::exists(&cur_symlink) {
        Ok(true) => { fs::remove_file(cur_symlink).unwrap(); },
        Ok(false) => (),
        Err(_) => (),
    }
}

fn restore(wallpapers_path: &String, cache_path: &String, unset: bool) -> Result<process::Output, std::io::Error> {
    let cur_symlink = format!("{cache_path}/{CUR_SYM}");
    let wallpaper = match fs::exists(&cur_symlink) {
        Ok(true) => match unset {
            true => {
                fs::remove_file(cur_symlink).unwrap();
                get_last_random_wallpaper(wallpapers_path, cache_path)
            },
            false => cur_symlink
        },
        Ok(false) => get_last_random_wallpaper(wallpapers_path, cache_path),
        Err(reason) => panic!("Failed to check if symlink exists: {}", reason),
    };
    apply_wallpaper(wallpaper)
}

fn set_wallpaper(wallpaper_abspath: PathBuf, cache_path: String) {
    let cur_symlink = format!("{cache_path}/{CUR_SYM}");
    match fs::exists(&cur_symlink) {
        Ok(true) => { fs::remove_file(&cur_symlink).unwrap(); },
        Ok(false) => (),
        Err(reason) => panic!("Failed to check if symlink exists: {}", reason),
    }
    symlink(wallpaper_abspath, &cur_symlink).unwrap();
    match apply_wallpaper(cur_symlink) {
        Ok(_) => (),
        Err(reason) => panic!("Failed to sed wallpaper: {}", reason),
    };
}

fn apply_wallpaper(wallpaper: String) -> Result<process::Output, std::io::Error> {
    process::Command::new("swaymsg").args(["output", "*", "bg", wallpaper.as_str(), "fill"]).output()
}

fn current_wallpaper(wallpapers_path: String, cache_path: String) {
    let cur_symlink = format!("{cache_path}/{CUR_SYM}");
    match fs::exists(&cur_symlink) {
        Ok(true) => println!("{}", cur_symlink),
        Ok(false) => println!("{}", get_last_random_wallpaper(&wallpapers_path, &cache_path)),
        Err(reason) => panic!("Failed to check if symlink exists: {}", reason),
    }
}

fn get_last_random_wallpaper(wallpapers_path: &String, cache_path: &String) -> String {
    let mut reader = BufReader::new(
        match fs::File::open(format!("{cache_path}/{HIST_FILE}")) {
            Ok(file) => file,
            Err(reason) => panic!("Failed to open history file: {}", reason),
        }
    );
    let mut last_wallpaper = String::new();
    reader.read_line(&mut last_wallpaper).unwrap();
    format!("{wallpapers_path}/{}", last_wallpaper.trim())
}
