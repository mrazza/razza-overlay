# media-sound/youtui

Youtui - a simple TUI YouTube Music player written in Rust aiming to implement an Artist->Albums workflow for searching for music, and using discoverability principles for navigation. Inspired by https://github.com/ccgauche/ytermusic/ and cmus.

Ytmapi-rs - an asynchronous API for YouTube Music using Google's internal API, Tokio and Reqwest. Inspired by https://github.com/sigma67/ytmusicapi/.

This project is not supported or endorsed by Google.

## Dependency Note
Youtui uses the Rodio library for playback which relies on Cpal https://github.com/rustaudio/cpal for ALSA support. The cpal readme mentions the that the ALSA development files are required which can be found in the following packages:
- libasound2-dev (Debian / Ubuntu)
- alsa-lib-devel (Fedora)
- alsa-lib (Arch)

