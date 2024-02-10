import json
import random
import re
import sys


def extract_id(s):
    pattern = r'song-of-the-day: "https://open\.spotify\.com/embed/track/(\w+)'
    match = re.search(pattern, s)
    if match:
        return match.group(1)
    return None


def replace_id(s, new_id):
    pattern = r'(song-of-the-day: "https://open\.spotify\.com/embed/track/)\w+'
    return re.sub(pattern, r"\1" + new_id, s)


def main():
    # Read the song library
    with open("assets/files/song_library.json", "r", encoding="utf-8") as file:
        song_library = json.load(file)

    # Select a random song
    song_id = random.choice(song_library)
    print(f"Selected song: {song_id}")

    # Read the current song of the day
    with open("_pages/music-corner.md", "r", encoding="utf-8") as file:
        lines = file.readlines()

    for i, line in enumerate(lines):
        if line.startswith("song-of-the-day:"):
            current_song_id = extract_id(line.strip())
            if current_song_id is None:
                print("No song of the day found")
                sys.exit(1)

            print(f"Current song: {current_song_id}")
            while current_song_id == song_id:
                print("Selecting a different song...")
                song_id = random.choice(song_library)
                print(f"Selected song: {song_id}")

            # Update the song of the day
            lines[
                i
            ] = f'song-of-the-day: "https://open.spotify.com/embed/track/{song_id}?utm_source=generator&theme=0"\n'
            break

    # Write the updated lines back to the file
    with open("_pages/music-corner.md", "w", encoding="utf-8") as file:
        file.writelines(lines)


if __name__ == "__main__":
    main()
