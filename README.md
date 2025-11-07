# auto-yelp-complimenter

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [How It Works](#how-it-works)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage Tips](#usage-tips)
- [Troubleshooting](#troubleshooting)
- [Safety, Privacy, and Etiquette](#safety-privacy-and-etiquette)
- [Roadmap Ideas](#roadmap-ideas)
- [License](#license)

## Overview
`auto_yelp_complimenter.scpt` is an AppleScript that runs directly against open Yelp tabs in Google Chrome. It automates the process of sending compliments to reviewers—no Yelp API, browser plugins, or keyloggers required. By interacting with the existing Yelp web interface, it keeps the experience human-friendly while still saving you time.

## Key Features
- **No APIs to manage**: Works entirely through the standard Yelp web UI.
- **Personalized compliments**: Extracts the reviewer's first name from the tab title and injects it into your message template.
- **Modal flow aware**: Opens the compliment modal, waits for it to appear, fills in your message, and submits it just like you would manually.
- **Safety pacing**: Adds configurable delays between actions and between tabs for a more natural cadence.
- **Resilient retries**: Detects the "Oops, something went wrong" modal error, refreshes the tab, and retries up to three times before giving up.
- **Window filtering**: Targets only Chrome tabs whose URLs contain `yelp.com`, keeping everything focused.

## How It Works
1. The script asks you for a compliment template when it starts. You can include `{name}` and it will be replaced by each reviewer’s first name.
2. AppleScript switches through every Chrome window and tab, looking for URLs that contain `yelp.com` (or whatever `URL_FILTER` is set to).
3. For each matching tab it:
   - Clicks the **Compliment** button using injected JavaScript.
   - Waits for the modal to appear.
   - Fills the textarea with your personalized message.
   - Waits again, then clicks **Send**.
4. After finishing with one tab, it pauses for a moment before moving on to the next Yelp tab.

## Prerequisites
- macOS with Script Editor (or another AppleScript runner).
- Google Chrome installed and already signed into Yelp.
- Yelp reviewer tabs open that you want to compliment.

## Getting Started
1. Open the project in Script Editor.
2. Review the constants at the top of `auto_yelp_complimenter.scpt` to ensure the default delays and URL filter fit your workflow.
3. Press **Run**.
4. When prompted, enter the compliment template text. Use `{name}` anywhere you want the reviewer’s first name to appear.
5. Confirm the dialog to begin the automation.

The script will activate Chrome, iterate through all Yelp tabs, and submit compliments with polite pacing. Logging happens via AppleScript’s `log` command, visible in Script Editor’s Event Log.

## Configuration
You can tune behavior by editing the properties near the top of the script:
- `ONLY_FRONT_WINDOW`: If `true`, only the currently focused Chrome window is processed.
- `URL_FILTER`: Tabs must contain this string to be included. Default is `"yelp.com"`.
- `MODAL_OPEN_DELAY`: Seconds to wait after clicking **Compliment** before touching the modal.
- `BEFORE_SEND_DELAY`: Seconds to wait after filling the message before clicking **Send**.
- `DELAY_BETWEEN_TABS`: Pause between tabs to keep interactions friendly.

## Usage Tips
- Keep Yelp tabs pre-loaded with the compliments you want to send for smoother execution.
- Use concise, genuine templates; the script personalizes them but authenticity still matters.
- If Yelp changes the layout, review the helper JavaScript functions before running again.
- Test with a small number of tabs to build confidence before scaling up.

## Troubleshooting
- **Nothing happens**: Confirm Chrome is running and that the tabs are loaded with Yelp content.
- **Modal not found**: Yelp may have updated its markup. Inspect the page and adjust query selectors in the helper functions if needed.
- **Compliment template error**: Ensure the modal text area accepts your message. Avoid excessively long text blocks.
- **Script stops early**: Check the Script Editor Event Log for entries such as `no-compliment`, `no-dialog`, or `no-send` to pinpoint the failing step.
- **Repeated "Oops" modal**: The script retries the compliment up to three times. If all attempts fail, it logs the reviewer as skipped so you can revisit manually.

## Safety, Privacy, and Etiquette
- Respect Yelp’s community guidelines and rate limits.
- Be mindful that automated interactions can still feel automated—keep messages kind and restrained.
- Review the personalized text before sending to avoid awkward substitutions.
- Avoid running the script unattended for long periods.

## Roadmap Ideas
- Toggle-able logging to a file for longer sessions.
- Randomized delay ranges for even more human-like pacing.
- Support for Safari or Chromium-based browsers beyond Chrome.
- GUI wrapper for easier configuration and scheduling.

## License
This project is released under the [Creative Commons Attribution-NonCommercial 4.0 International License](LICENSE). You are welcome to share and adapt the script for educational or personal projects, but commercial use is not permitted. Please credit **Misha Lubich** ([GitHub](https://github.com/ml-lubich)).

