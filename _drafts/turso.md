---
title: "Turso"
excerpt: "Turso is actually two databases sharing one name: a mature SQLite fork in maintenance mode and a from-scratch Rust rewrite that hasn't hit 1.0 yet. I ran both against a small Go CRUD example, including the embedded replica pattern, to see where the project actually stands."
tagline: "One name, two databases, and you need to know which one you're running"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/demos/turso/turso.webp
tags:
  - go
  - database
mermaid: true
---

## Overview

SQLite is a C library, not a server. There's no separate process to start and no port to open: the entire engine links directly into your application and reads and writes a single file on disk. That's the whole design, and it's why SQLite is the database most of us already have, whether we asked for it or not. It ships inside your phone, your browser, half the CLIs on your machine, because zero-config and zero-ops beats a dedicated database server for the enormous share of workloads that only ever need one process touching the data at a time.

The catch has always been the same: it's a single file on a single disk, which makes it wonderful for local development and awkward for anything that needs to run close to users in more than one region, or sync between a server and an edge location.

Turso tries to close that gap. It takes SQLite's file format and adds the pieces SQLite was never built for: remote access over HTTP, local replicas that sync from a primary, vector types for embeddings, and a hosted platform to run all of it. That pitch is straightforward. What's less straightforward is that "Turso" doesn't point at one thing. It points at two different database engines and a hosting product, all wearing the same name, and figuring out which one you're actually reading about takes more effort than it should.

## Understanding Turso

Start with the original project. In 2022, the company behind Turso forked SQLite in C and called the fork libSQL. The fork lives at [github.com/tursodatabase/libsql](https://github.com/tursodatabase/libsql), and it's the database that gave Turso its early features: embedded replicas, an HTTP and WebSocket protocol for remote access, native vector columns. It has been stable and production-grade for a while. It's also, as of this writing, done growing. The last server release, `libsql-server-v0.24.32`, shipped on February 14, 2025, and nothing has followed it since. The project's own documentation now tells new users to look at Turso instead, because libSQL is maintained but no longer where new features land.

Then there's Turso itself, the thing that inherited the name. In early 2025, the same team started a side project codenamed Limbo: a ground-up rewrite of SQLite in Rust, not a fork, a new implementation from the file format up. Limbo was later renamed Turso, which means the database engine, the company, and the cloud product now all answer to the same word in casual conversation. This isn't a coincidence. It's closer to a company deciding its old fork was the wrong long-term bet and quietly starting over, then handing the new thing the brand it had already built.

That new engine lives at [github.com/tursodatabase/turso](https://github.com/tursodatabase/turso), and it is not finished. Its own FAQ says the project "powers production applications today," which is a real claim, but it also hasn't reached 1.0. The gaps that remain before it does are specific and mostly known: multiprocess support and `VACUUM` are the two the maintainers point to most often. It ships weekly, which is a healthy pace for a young rewrite and also a signal that you shouldn't treat any given commit as a stable target.

<div class="mermaid">
graph LR
    SQLite -->|"forked in C, 2022"| libSQL
    libSQL -->|"maintained, no new features"| Cloud["Turso Cloud (hosted product)"]
    libSQL -.->|"superseded by"| Limbo["Limbo, 2025"]
    Limbo -->|renamed| Turso["Turso (Rust rewrite, pre-1.0)"]
    Turso --> Cloud
</div>

So when someone says "we're using Turso," ask which one. Are they on the older libSQL server, still solid but no longer evolving? Or on the new Rust engine, fast-moving and pre-1.0? Or, more likely, on Turso Cloud, the managed hosting product, which markets itself simply as "Turso" and blurs the distinction on purpose because most users never need to know which engine sits underneath. All three are documented, not speculative: `github.com/tursodatabase/libsql`, `github.com/tursodatabase/turso`, and [turso.tech/what-is-turso](https://turso.tech/what-is-turso) lay out the history if you want the primary sources. I'm flagging it here because it changes how you should read every feature claim in the rest of this post: some of what follows is mature libSQL behavior, some is the newer engine, and the boundary matters more than the marketing lets on.

## Key Features

With the naming out of the way, here's what Turso (in the broad, marketing sense) actually gives you over plain SQLite:

- **Remote access over HTTP and WebSocket.** A libSQL-compatible server accepts connections the way a normal client-server database would, instead of requiring a file on local disk.
- **Embedded replicas.** A local SQLite file that stays synced with a remote primary. Reads hit the local file, which is fast and works offline; writes go to the primary and get pulled back down on the next sync.
- **Vector types.** An `F32_BLOB(n)` column type plus distance functions, so you can store embeddings next to your relational data instead of standing up a separate vector store.
- **Branching**, on Turso Cloud: copy-on-write branches of a hosted database, created almost instantly, useful for the same reason git branches are useful for code. This is a cloud-only feature backed by Turso Cloud's group and organization infrastructure; it isn't something you can exercise against a local server.
- **Multi-region distribution**, also cloud-only: databases replicated across regions so reads happen close to users.
- **A local dev server**, `turso dev`, that spins up a real libSQL-compatible instance on your machine with no account and no login.

That last one is the feature I actually want to spend the rest of this post on, because it's the part you can try right now, and it's the closest thing here to what Testcontainers gives you with Docker: a real instance to point your code at, without touching anything hosted.

## Getting Started with Turso

Installing the CLI is a single script:

{% highlight bash %}
{% raw %}
curl -sSfL https://get.tur.so/install.sh | bash
{% endraw %}
{% endhighlight %}

This drops the `turso` binary into `~/.turso` and updates your shell profile so it's on `PATH`. Once it's installed, check the version:

{% highlight bash %}
{% raw %}
turso version
# v1.0.30
{% endraw %}
{% endhighlight %}

Now start a local server. No account, no login, nothing but a database file on disk.

{% highlight bash %}
{% raw %}
turso dev --db-file local.db
{% endraw %}
{% endhighlight %}

This is what it prints on startup:

{% highlight text %}
{% raw %}
sqld listening on port 8080.
Use the following URL to configure your libSQL client SDK for local development:

    http://127.0.0.1:8080

By default, no auth token is required when sqld is running locally. If you want to require authentication, use --auth-jwt-key-file to specify a file containing the JWT key.

Using database file local.db.
{% endraw %}
{% endhighlight %}

Worth noting: if your client SDK can already talk to a plain SQLite file, you don't need `turso dev` at all. Its own `--help` text says as much: use a `file:` URL and skip the server entirely. `turso dev` earns its keep when you want your local setup to look like the remote, HTTP-shaped Turso your code will eventually talk to in production, embedded replicas included.

Leave that server running. In another terminal, write some Go against it. First, get the driver:

{% highlight bash %}
{% raw %}
go get github.com/tursodatabase/go-libsql@latest
{% endraw %}
{% endhighlight %}

There are no tagged releases yet, so `@latest` resolves to a pseudo-version like `v0.0.0-20260424063416-3051e37e6e04`. The package uses CGO, so every build and run needs `CGO_ENABLED=1`. It registers itself as a `database/sql` driver named `libsql`, and the driver picks its behavior from the URL scheme: `file:` or `:memory:` for a local file, `http://`, `https://`, or `libsql://` for a remote connection.

Here's a small program that connects to the local dev server and runs through a full CRUD cycle on a table of songs.

{% highlight go %}
{% raw %}
package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"

	_ "github.com/tursodatabase/go-libsql"
)

type Song struct {
	ID       string
	Name     string
	Composer string
}

func main() {
	ctx := context.Background()

	db, err := sql.Open("libsql", "http://127.0.0.1:8080")
	if err != nil {
		log.Fatalf("failed to open db: %s", err)
	}
	defer db.Close()

	if err := db.PingContext(ctx); err != nil {
		log.Fatalf("failed to ping db: %s", err)
	}
	fmt.Println("connected to local turso dev server")

	_, err = db.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS songs (
		id TEXT PRIMARY KEY,
		name TEXT NOT NULL,
		composer TEXT NOT NULL
	)`)
	if err != nil {
		log.Fatalf("failed to create table: %s", err)
	}
	fmt.Println("created songs table")

	songs := []Song{
		{ID: "1", Name: "Clair de Lune", Composer: "Debussy"},
		{ID: "2", Name: "Gymnopedie No. 1", Composer: "Satie"},
	}
	for _, s := range songs {
		_, err = db.ExecContext(ctx, "INSERT INTO songs (id, name, composer) VALUES (?, ?, ?)", s.ID, s.Name, s.Composer)
		if err != nil {
			log.Fatalf("failed to insert song: %s", err)
		}
	}
	fmt.Println("inserted 2 songs")

	rows, err := db.QueryContext(ctx, "SELECT id, name, composer FROM songs ORDER BY id")
	if err != nil {
		log.Fatalf("failed to query songs: %s", err)
	}
	fmt.Println("all songs:")
	for rows.Next() {
		var s Song
		if err := rows.Scan(&s.ID, &s.Name, &s.Composer); err != nil {
			log.Fatalf("failed to scan song: %s", err)
		}
		fmt.Printf("  %+v\n", s)
	}
	rows.Close()

	_, err = db.ExecContext(ctx, "UPDATE songs SET composer = ? WHERE id = ?", "Erik Satie", "2")
	if err != nil {
		log.Fatalf("failed to update song: %s", err)
	}
	var updatedComposer string
	if err := db.QueryRowContext(ctx, "SELECT composer FROM songs WHERE id = ?", "2").Scan(&updatedComposer); err != nil {
		log.Fatalf("failed to fetch updated song: %s", err)
	}
	fmt.Printf("updated song 2 composer to: %s\n", updatedComposer)

	_, err = db.ExecContext(ctx, "DELETE FROM songs WHERE id = ?", "1")
	if err != nil {
		log.Fatalf("failed to delete song: %s", err)
	}
	var count int
	if err := db.QueryRowContext(ctx, "SELECT COUNT(*) FROM songs").Scan(&count); err != nil {
		log.Fatalf("failed to count songs: %s", err)
	}
	fmt.Printf("deleted song 1, remaining rows: %d\n", count)
}
{% endraw %}
{% endhighlight %}

Nothing here is Turso-specific past the `sql.Open("libsql", ...)` call. It's `database/sql`, the same interface you'd use against PostgreSQL or MySQL. Run it with `CGO_ENABLED=1 go run main.go` and you get:

{% highlight text %}
{% raw %}
connected to local turso dev server
created songs table
inserted 2 songs
all songs:
  {ID:1 Name:Clair de Lune Composer:Debussy}
  {ID:2 Name:Gymnopedie No. 1 Composer:Satie}
updated song 2 composer to: Erik Satie
deleted song 1, remaining rows: 1
{% endraw %}
{% endhighlight %}

You can also poke at the same server directly from the CLI, without writing any code:

{% highlight bash %}
{% raw %}
turso db shell http://127.0.0.1:8080 "select * from songs;"
{% endraw %}
{% endhighlight %}

{% highlight text %}
{% raw %}
ID     NAME                 COMPOSER
2      Gymnopedie No. 1     Erik Satie
{% endraw %}
{% endhighlight %}

That confirms the delete and the update both landed. No login needed either: the local dev server never asks for one.

Now for the feature that actually distinguishes Turso from "SQLite with an HTTP wrapper": embedded replicas. The idea is a local file that stays synced with a remote primary, so reads are local and fast while writes go through the primary.

<div class="mermaid">
sequenceDiagram
    participant App as Go program
    participant Replica as Local replica file
    participant Primary as turso dev (primary)

    App->>Primary: write (INSERT / UPDATE / DELETE)
    App->>Primary: connector.Sync()
    Primary-->>Replica: sync frames down
    App->>Replica: read (SELECT)
    Replica-->>App: rows, no network round trip
</div>

Here's a second program, run right after the first one against the same still-running `turso dev` server, that creates a replica and syncs it.

{% highlight go %}
{% raw %}
package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/tursodatabase/go-libsql"
)

func main() {
	ctx := context.Background()

	dbPath := "replica-local.db"
	os.Remove(dbPath)
	defer os.Remove(dbPath)

	connector, err := libsql.NewEmbeddedReplicaConnector(dbPath, "http://127.0.0.1:8080")
	if err != nil {
		log.Fatalf("failed to create embedded replica connector: %s", err)
	}
	defer connector.Close()

	db := sql.OpenDB(connector)
	defer db.Close()

	replicated, err := connector.Sync()
	if err != nil {
		log.Fatalf("failed to sync: %s", err)
	}
	fmt.Printf("synced from primary: frameNo=%d framesSynced=%d\n", replicated.FrameNo, replicated.FramesSynced)

	var count int
	if err := db.QueryRowContext(ctx, "SELECT COUNT(*) FROM songs").Scan(&count); err != nil {
		log.Fatalf("failed to query replicated table: %s", err)
	}
	fmt.Printf("read from local embedded replica file, songs count: %d\n", count)

	var name, composer string
	if err := db.QueryRowContext(ctx, "SELECT name, composer FROM songs WHERE id = ?", "2").Scan(&name, &composer); err != nil {
		log.Fatalf("failed to query row: %s", err)
	}
	fmt.Printf("song 2 from local replica: %s by %s\n", name, composer)

	info, err := os.Stat(dbPath)
	if err != nil {
		log.Fatalf("failed to stat replica file: %s", err)
	}
	fmt.Printf("local replica file on disk: %s (%d bytes)\n", dbPath, info.Size())
}
{% endraw %}
{% endhighlight %}

`NewEmbeddedReplicaConnector` takes a local file path and a primary URL and returns a connector you hand to `sql.OpenDB`. Calling `connector.Sync()` pulls the latest frames from the primary down into that local file (there's also a periodic-sync variant via `libsql.WithSyncInterval`, though I only exercised the manual call here). After that, every read comes straight off disk, no network round trip required. Run it with `CGO_ENABLED=1 go run ./replica` and you get:

{% highlight text %}
{% raw %}
synced from primary: frameNo=9 framesSynced=0
read from local embedded replica file, songs count: 1
song 2 from local replica: Gymnopedie No. 1 by Erik Satie
local replica file on disk: replica-local.db (4096 bytes)
{% endraw %}
{% endhighlight %}

The row count reads 1, not 2, because the first program had already deleted song 1 and renamed song 2's composer before this ran. The sync correctly carries that state onto the local file, which is the whole point: the replica isn't a snapshot from whenever it was created, it's whatever the primary looked like at the last sync.

One more feature worth trying while the server is still up: vector search. Turso stores embeddings as a native column type and gives you distance functions and an index type to query them, no separate vector database required.

Here's a slightly more realistic setup than a bare number pair: three short documents, each with a small embedding, where two are related and one clearly isn't.

{% highlight sql %}
{% raw %}
CREATE TABLE docs (id INTEGER PRIMARY KEY, title TEXT, embedding F32_BLOB(4));
INSERT INTO docs (id, title, embedding) VALUES (1, 'sqlite basics', vector('[0.9,0.1,0.0,0.0]'));
INSERT INTO docs (id, title, embedding) VALUES (2, 'turso embedded replicas', vector('[0.85,0.15,0.05,0.0]'));
INSERT INTO docs (id, title, embedding) VALUES (3, 'baking sourdough bread', vector('[0.0,0.0,0.1,0.95]'));
{% endraw %}
{% endhighlight %}

Cosine distance ranks them the way you'd hope: the two database-related documents come back close together, and the bread recipe sits far away.

{% highlight sql %}
{% raw %}
SELECT id, title, vector_distance_cos(embedding, vector('[0.9,0.1,0.0,0.0]')) as cos_dist
FROM docs ORDER BY cos_dist;
{% endraw %}
{% endhighlight %}

{% highlight text %}
{% raw %}
ID     TITLE                       COS DIST
1      sqlite basics               -0.000000008935383100094896
2      turso embedded replicas     0.003718482330441475
3      baking sourdough bread      1
{% endraw %}
{% endhighlight %}

`vector_distance_l2` gives the same ordering under a different metric:

{% highlight sql %}
{% raw %}
SELECT id, title, vector_distance_l2(embedding, vector('[0.9,0.1,0.0,0.0]')) as l2_dist
FROM docs ORDER BY l2_dist;
{% endraw %}
{% endhighlight %}

{% highlight text %}
{% raw %}
ID     TITLE                       L2 DIST
1      sqlite basics               0
2      turso embedded replicas     0.08660251647233963
3      baking sourdough bread      1.3162446022033691
{% endraw %}
{% endhighlight %}

Scanning every row with a distance function is fine at the size of this demo, but it's a full table scan. For anything bigger, Turso supports an approximate nearest-neighbor index over the same column:

{% highlight sql %}
{% raw %}
CREATE INDEX docs_embedding_idx ON docs (libsql_vector_idx(embedding));
SELECT id FROM vector_top_k('docs_embedding_idx', vector('[0.9,0.1,0.0,0.0]'), 2);
{% endraw %}
{% endhighlight %}

{% highlight text %}
{% raw %}
ID
1
2
{% endraw %}
{% endhighlight %}

`vector_top_k` returns the two nearest rows by ID, the same pair the distance queries ranked highest, now served from an index instead of a full scan. `F32_BLOB(n)`, `vector()`, `vector_distance_cos()`, `vector_distance_l2()`, and the ANN index all work today, entirely locally.

What I didn't try, deliberately, is branching. I ran `turso db branch` against the local dev server out of curiosity and got exactly what you'd expect: "You are not logged in, please login with turso auth login before running other commands." Branching is a Turso Cloud feature, built on the hosted platform's group and organization structure, and it's a genuinely useful one: copy-on-write branches of a hosted database, created in something close to real time, available even on the free tier. But it needs a real account. So does multi-region distribution. Neither is something you can wire up against `turso dev`, and I'd rather say that plainly than show you a command that only works after a login step I skipped.

If you do want to go further, Turso Cloud's free tier gives you 100 databases, 5GB of storage, 500 million rows read and 10 million rows written per month, 3GB of sync traffic, and one day of point-in-time recovery. Paid tiers start at $4.99 a month for the Developer plan.

## Best Practices

A few things I'd keep in mind before putting any of this in front of real traffic.

Pin your versions instead of tracking `@latest`. The Go SDK has no tagged releases yet and the underlying engine ships weekly, which means the code you tested against yesterday can behave differently today. Record the exact pseudo-version or commit you built against, and update it on your own schedule, not by accident.

Keep independent backups. This isn't me being cautious for its own sake, it's the project's own FAQ saying it: a pre-1.0 database, however well it performs in production today, is not somewhere you want your only copy of anything.

Be explicit about which Turso you mean. Say it out loud in your own documentation and in conversation with teammates: are you on the libSQL server, the new Rust engine, or Turso Cloud sitting on top of one of them. The overlap in naming is real and it will cause a confused debugging session at some point if nobody writes it down.

Don't build cloud-only features into code you expect to test locally. Branching and multi-region distribution need a Turso Cloud account. If your local development loop leans on `turso dev`, keep that loop honest about what it can and can't exercise, and gate anything cloud-dependent behind an integration test that runs against the real thing.

## Summary

Turso is two databases and a hosting product wearing one name: libSQL, the original C fork, stable but in maintenance mode; the new Rust rewrite that inherited the Turso name, fast-moving and pre-1.0; and Turso Cloud, the managed platform most people mean when they say "Turso" out loud. `turso dev` gives you a real local server to build against without an account, and the Go SDK's embedded replica pattern, a local file kept in sync with a remote primary, is the feature that actually earns the comparison to a client-server database. Vector search works locally too. Branching and multi-region distribution don't, not without logging in, and that's fine as long as you know it going in.

## Resources

- [**Turso**](https://turso.tech/)
- [**What is Turso?**](https://turso.tech/what-is-turso)
- [**libSQL (tursodatabase/libsql)**](https://github.com/tursodatabase/libsql)
- [**Turso database engine (tursodatabase/turso)**](https://github.com/tursodatabase/turso)
- [**Go SDK (tursodatabase/go-libsql)**](https://github.com/tursodatabase/go-libsql)
- [**Branching**](https://docs.turso.tech/features/branching)
