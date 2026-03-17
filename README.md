<div align="center">
  <img src="web/icons/favicon.svg" alt="logo" width="100" height="100">
  <h1>MetroNext Taipei</h1>
</div>

<div align="center">
  <p>A minimalist, cross-platform companion app for the Taipei Metro system.</p>
</div>

[正體中文 (Traditional Chinese)](README.zh-TW.md)

## 📸 Screenshots

| Screenshot 1 | Screenshot 2 |
| :---: | :---: |
| ![App Screenshot 1](docs/images/screenshot.png) | ![App Screenshot 2](docs/images/screenshot1.png) |
| *App Screenshot 1* | *App Screenshot 2* |

## Features

*   **Real-time Train Countdown:** Get live arrival and departure information for all metro lines.
*   **Nearest Station Finder:** Instantly locate the metro station closest to you using your device's location.

## TODO

*   **Comprehensive Station Details:** Access in-depth information about every station, including:
    *   Station layout and maps.
    *   Exit and entrance locations.
    *   Availability of facilities like elevators, escalators, restrooms, ATMs, and charging stations.
*   **English Support:** Add localization for English language users.

## Supported Platforms

*   Android
*   Web

## Download

You can download the latest Android APK from the [releases page](https://github.com/wyrindev/metro-next-taipei/releases).

## Getting Started

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install)

### Installation

1.  Clone the repository:
    ```sh
    git clone https://github.com/wyrindev/metro-next-taipei.git
    ```
2.  Navigate to the project directory:
    ```sh
    cd metro-next-taipei
    ```
3.  Install the dependencies:
    ```sh
    flutter pub get
    ```

### Running the Application

*   Run the app on your connected device or emulator:
    ```sh
    flutter run
    ```

## Building for Production

### Android

*   To build an APK:
    ```sh
    flutter build apk
    ```
*   To build an App Bundle:
    ```sh
    flutter build appbundle
    ```

### Web

*   To build the web application:
    ```sh
    flutter build web
    ```
The output will be in the `build/web` directory.