import argparse
import json

import spotipy


def fetch_songs(
    client_id: str,
    client_secret: str,
    playlist_id: str,
):
    sp = spotipy.Spotify(
        auth_manager=spotipy.oauth2.SpotifyClientCredentials(
            client_id=client_id,
            client_secret=client_secret,
        ),
        requests_session=True,
    )
    offset = 0
    songs = []
    while True:
        response = sp.playlist_items(
            playlist_id,
            offset=offset,
            fields="items.track.id, items.track.name, items.track.external_urls.spotify, total",
            additional_types=["track"],
        )
        if len(response["items"]) == 0:
            break
        no_tracks = len(response["items"])
        for t in response["items"][:no_tracks]:
            if t["track"]["id"]:
                songs.append(t["track"]["id"])
        offset += no_tracks
    return songs


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--client-id",
        type=str,
        help="Spotify client id",
    )
    parser.add_argument(
        "--client-secret",
        type=str,
        help="Spotify client secret",
    )
    parser.add_argument(
        "--playlist-id",
        type=str,
        default="4qzTZILeEqxbybKyv0BuPh",
        help="Spotify playlist id",
    )
    parser.add_argument(
        "--output-file",
        type=str,
        default="assets/files/song_library.json",
        help="Output file",
    )
    args = parser.parse_args()
    songs = fetch_songs(
        client_id=args.client_id,
        client_secret=args.client_secret,
        playlist_id=args.playlist_id,
    )
    with open(file=args.output_file, mode="w", encoding="utf-8") as output_file:
        json.dump(songs, output_file)
        print(f"Saved {len(songs)} songs to {args.output_file}")


if __name__ == "__main__":
    main()
