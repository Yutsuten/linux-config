# MVI

[Mpv](https://github.com/mpv-player/mpv) used as an image viewer.

Based on the awesome configurations provided in the repositories bellow:

- [occivink/mpv-image-viewer](https://github.com/occivink/mpv-image-viewer)
- [occivink/mpv-gallery-view](https://github.com/occivink/mpv-gallery-view)

Wrapper script is at `desktop/bin/mvi` in this repository.

## Changes

### Thumbnail generation in two phases

The original `playlist-view.lua` script saves raw BGRA images in the configured directory. Raw images consume a lot of disk space so I decided to improve this by doing the thumbnail generation in two phases.

- **Phase 1:** Resize the original image to the size configured for thumbnails, and save it in a *compressed* format in the configured directory. By default we use `webp` but it is configurable. This step is the most time and CPU intensive because we may be dealing with huge images.
- **Phase 2:** Using the image generated in phase 1, we convert it to raw BGRA and save it in a temporary directory, usually `/tmp/`. When closing the program, the folder with raw BGRA thumbnails is erased. We can repeat this step everytime with minimal time and CPU usage because the source images are small.

To make the process "feel" faster, we also pre-process all opened images with in background. This pre-processing is the phase 1 mentioned above. So the first time opening a batch of images may consume a lot of CPU, but after phase 1 finished for all your images, only phase 2 is needed and therefore very fast.
This way we achieve the best of both worlds: save disk usage and fast thumbnails generation.

### Single worker thumbnail generation

The original script allowed the user to create multiple copies of the `gallery-thumbgen.lua` script to allow parallel processing. This feature was removed here.

My reasoning is that the pre-processing does its job quite well. Even if opening a batch of images for the first time, a few seconds is enough to pre-process all the images shown in the first page of the gallery. And it begins *before* opening the gallery.
Also I save my config files in git, and don't want to save multiple copies of the same script. There may be ways to workaround this, but I don't think it worths the trouble.

### New dependency: imagemagick

The original script would allow the user to use `ffmpeg` or `mpv` for thumbnails generation, but `imagemagick` seemed to be a better fit for the two-phased thumbnail generation. 
Supporting multiple tools for thumbnail generation is certainly possible, but it's more work and testing needed for something probably only I will use. And I always have `imagemagick` installed.

### Delete not accessed thubnails in X days

This is configurable by changing `delete_old_thumbs_in_days` in `mvi/script-opts/playlist_view.conf`. This removes thumbnails generated in phase 1 that potentially don't exist anymore.

### Drop Windows support

Not sure if the original scripts were supposed to work on Windows too, but here definitively it isn't supported. Several Linux-only tools are being used:

- `magick` (may be installable on Windows too)
  - For thumbnails generation
- `mktemp`
  - To generate the temporary directory for BGRA images
- `rm`
  - To delete the temporary directory of BGRA images
- `mkdir` (with `-p` option)
  - To create the user-defined thumbnail directory if it doesn't exist, used for phase 1
- `find`
  - To automatically delete not accessed thumbnails
