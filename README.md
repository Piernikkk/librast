# librast

Play your favourite brain-fu\*\*ing puzzle game!

This is all you need to waste huge amount of time and not be productive at all.

Beat you highscores or something idk but this time without annoying adds and other data mining, privacy invading features.

![game](images/game.png)

## How to play:

Your goal is to place the blocks on the grid so everything fits and clear rows and columns by making straight lines from the blocks. I guess you know the drill.

## Features:

- Main screen with buttons and high score indicator
- Settings in which you can change completely nothing (actual setting comming soon™)
- Game with different shaped blocks
- Auto snapping grid (or at least i tried to make it that way)
- Game logic that detects if you can't place any more blocks
- Score
- Pause menu
- Haptic feedback

## Assets Used:

I guess i only used settings icon from [tabler](https://tabler.io/icons). The rest is just godot colored sprites.

## Tech Stack:

This project is built with [Godot](https://godotengine.org/) Engine with `GDScript`. Also a bit of figma to mage png for settings icon.

## Project Setup:

This is just a godot game so everyting you need to do is:

1. Clone this repo: git clone `https://github.com/Piernikkk/librast.git`
2. Open godot
3. Click Import -> Browse -> Select cloned repo -> Import

## Building:

### Dependencies:

You need to have android studio installed on your machine, or at least I think it's the easiest way to obtain needed toolchain. You also need to install java, godot recomends [jdk 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html), depends on your os, but on fedora it's just `sudo dnf install -y java-21-openjdk-devel`. And you need to give godot your java path in Editor settings (just search for java under `Editor` -> `Editor Settings` options at the top of the godot window). For me it was `/usr/lib/jvm/java-17-openjdk/`.

### Building:

You just go to `Project` -> `Export`, select android and click export project. All settings should be there loaded from export presets file in repo.
