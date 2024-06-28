---
title: "Testcontainers"
excerpt: "Discover the power of Testcontainers, a versatile library simplifying Docker container management for testing. Explore its mechanics, features, and practical applications in creating reliable and reproducible test environments."
tagline: "Streamline your testing workflow with Testcontainers"
header:
  overlay_color: "#24292f"
  teaser: assets/images/demos/testcontainers/testcontainers.webp
tags:
  - go
  - testing
---

## Overview

Testing code, especially when it involves complex data stores and dependencies, can be a challenge in software development. It is crucial to accurately replicate real-world conditions for thorough testing. Testcontainers is a tool that integrates Docker containers into your testing process, making it easier to create a lifelike and controlled testing environment. This article explores the complexities of testing in software development and how Testcontainers helps address these challenges.

## Understanding Testcontainers

Testcontainers is an open-source library that simplifies the management of Docker containers for testing purposes. It enables you to create and control lightweight, disposable instances of databases, web browsers, and other services in your integration tests. By using Docker containers, Testcontainers ensures that your tests run in consistent and reproducible environments, free from the variability of external dependencies.

Originally developed for the Java ecosystem, Testcontainers now supports multiple programming languages, including Java, Go, and Node.js, making it a versatile tool for modern development workflows.

## The Mechanics of Testcontainers

Testcontainers work by managing the lifecycle of Docker containers used in your tests. Here's an outline of the key steps involved:

1. **Container Definition**: You start by specifying the Docker image and any necessary configuration settings, such as environment variables, exposed ports, and initialization commands. This setup is encapsulated in a container definition.
2. **Container Startup**: Before running your tests, Testcontainers launches the specified containers to ensure they are fully started and ready for use. It employs wait strategies to confirm that services within the containers are running appropriately.
3. **Test Execution**: Your tests interact with the services running inside the containers. Each test gets a fresh instance of the container, avoiding issues related to shared state or resource conflicts and ensuring that your tests are isolated and reliable.
4. **Teardown**: After the tests are complete, Testcontainers stops and removes the containers, cleaning up resources and preventing any leftover state from affecting future tests. This automated cleanup is crucial for maintaining a tidy and predictable testing environment.

## Features of Testcontainers

Testcontainers provide a comprehensive set of features, making it an invaluable tool for testing intricate systems and applications. Some of the key features include:

- **Automatic Lifecycle Management**: Testcontainers handle the start and stop of containers, ensuring they are available when needed and properly disposed of afterward.
- **Wait Strategies**: The library provides various strategies to wait until the containerized service is ready, such as waiting for a specific log message, a network port to be open, or a health check to pass.
- **Network Configuration**: You can configure network settings to mimic production environments, including setting up container networks and linking multiple containers together.
- **Extensibility**: Testcontainers supports custom extensions and modules, allowing you to tailor it to your specific testing requirements.

## Advantages of Testcontainers

Testcontainers offer several benefits that can significantly improve your testing process.

Some of the key advantages include:
- **Isolation and Consistency**: Each test runs in a fresh container, ensuring no cross-test interference and consistent test environments across different machines.
- **Simplified Setup**: By abstracting the complexity of Docker container management, Testcontainers makes it easier to set up and tear down test dependencies.
- **Reproducibility**: Docker containers encapsulate the entire runtime environment, enabling accurate reproduction of issues and testing of scenarios.
- **Integration Testing**: Testcontainers are excellent for integration testing scenarios that require interaction with external systems such as databases, message brokers, or web servers. Containers offer a realistic and controlled environment for these interactions.

Regardless of the complexity of your application or the dependencies it relies on, Testcontainers can help streamline your testing workflow and ensure the reliability and robustness of your tests.
Particular cases where Testcontainers can be beneficial include:
- **Database Testing**: Use Testcontainers to spin up instances of databases (e.g., PostgreSQL, MySQL) with specific versions, enabling you to test against multiple database configurations and ensure compatibility.
- **Microservices**: Test interactions between different microservices by running each service in its container, simulating real-world deployments.
- **Third-Party APIs**: Mock third-party APIs or services using containers, providing a controlled and isolated environment for testing API integrations.
- **Version Compatibility Testing**: Validate that your application works with different database versions by running tests against multiple containerized instances, each with a different version.
- **Continuous Integration**: Integrate Testcontainers into your CI/CD pipeline to automatically set up test environments, run integration tests, and tear down environments after completion.
- **Environment Simulation**: Simulate different production environments by configuring containers to match the settings and constraints of your production systems.

## Getting Started with Testcontainers

To demonstrate the power of Testcontainers, let's look at a simple example using Go, Redis, and PostgreSQL. We'll write a test that spins up Redis and PostgreSQL containers, interacts with them, and then shuts them down after the test completes.

The content of the example is available in this [GitHub repository](https://github.com/christosgalano/testcontainers-example).

> **Note**: Keep in mind that for the tests to run, you need to meet these [requirements](https://golang.testcontainers.org/system_requirements/docker/).

Our project has the following structure:

{% highlight plaintext %}
{% raw %}
testcontainers-example/
├──model/
│   └── song.go
├──repository/
│   ├──song.go
│   ├──redis/
│   │   ├──redis.go
│   │   ├──redis_test.go
│   │   └──testdata/
│   │       └──songs.json
│   └──postgres/
│       ├──postgres.go
│       ├──postgres_test.go
│       └──testdata/
│           └──init-song-db.sql
├──go.sum
└──go.mod
{% endraw %}
{% endhighlight %}

In this example, we have a simple application that performs CRUD operations on songs.

{% highlight go %}
{% raw %}
// model/song.go
package model

// Song represents a music song.
type Song struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Composer string `json:"composer"`
}
{% endraw %}
{% endhighlight %}

The repository package defines a song repository interface for interacting with the data store:

{% highlight go %}
{% raw %}
// repository/song.go
package repository

import (
	"github.com/christosgalano/testcontainers-demo/model"
)

// SongRepository defines the methods for managing songs.
type SongRepository interface {
	GetAll() ([]model.Song, error)
	GetByID(id string) (*model.Song, error)
	Create(song*model.Song) error
	Update(song *model.Song) error
	Delete(id string) error
}
{% endraw %}
{% endhighlight %}

The repository package also contains implementations for Redis and PostgreSQL data stores.

<details>
  <summary>repository/redis/redis.go</summary>
{% highlight go %}
{% raw %}
package repository

import (
	"context"
	"encoding/json"

	"github.com/go-redis/redis/v8"

	"github.com/christosgalano/testcontainers-demo/model"
)

// RedisSongRepository is a Redis implementation of SongRepository.
type RedisSongRepository struct {
	client *redis.Client
}

// GetAll returns all songs.
func (r *RedisSongRepository) GetAll(ctx context.Context) ([]model.Song, error) {
	keys, err := r.client.Keys(ctx, "*").Result()
	if err != nil {
		return nil, err
	}
	var songs []model.Song
	for _, key := range keys {
		val, err := r.client.Get(ctx, key).Result()
		if err != nil {
			return nil, err
		}
		var song model.Song
		err = json.Unmarshal([]byte(val), &song)
		if err != nil {
			return nil, err
		}
		songs = append(songs, song)
	}
	return songs, nil
}

// GetByID returns a song by ID.
func (r *RedisSongRepository) GetByID(ctx context.Context, id string) (*model.Song, error) {
	val, err := r.client.Get(ctx, id).Result()
	if err != nil {
		return nil, err
	}
	var song model.Song
	err = json.Unmarshal([]byte(val), &song)
	if err != nil {
		return nil, err
	}
	return &song, nil
}

// Create creates a new song.
func (r *RedisSongRepository) Create(ctx context.Context, song*model.Song) (*model.Song, error) {
	songJSON, err := json.Marshal(song)
	if err != nil {
		return nil, err
	}
	err = r.client.Set(ctx, song.ID, songJSON, 0).Err()
	if err != nil {
		return nil, err
	}
	return song, nil
}

// Update updates an existing song.
func (r *RedisSongRepository) Update(ctx context.Context, song*model.Song) (*model.Song, error) {
	return r.Create(ctx, song) // In Redis, update can be done using the same method as create
}

// Delete deletes a song by ID.
func (r *RedisSongRepository) Delete(ctx context.Context, id string) error {
	err := r.client.Del(ctx, id).Err()
	if err != nil {
		return err
	}
	return nil
}
{% endraw %}
{% endhighlight %}
</details>

<details>
  <summary>repository/postgres/postgres.go</summary>
{% highlight go %}
{% raw %}
package repository

import (
	"context"
	"database/sql"

	"github.com/christosgalano/testcontainers-demo/model"
)

// PostgresSongRepository is a PostgreSQL implementation of SongRepository.
type PostgresSongRepository struct {
	db *sql.DB
}

// GetAll returns all songs.
func (r *PostgresSongRepository) GetAll(ctx context.Context) ([]model.Song, error) {
	rows, err := r.db.QueryContext(ctx, "SELECT id, name, composer FROM songs")
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var songs []model.Song
	for rows.Next() {
		var song model.Song
		if err := rows.Scan(&song.ID, &song.Name, &song.Composer); err != nil {
			return nil, err
		}
		songs = append(songs, song)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return songs, nil
}

// GetByID returns a song by ID.
func (r *PostgresSongRepository) GetByID(ctx context.Context, id string) (*model.Song, error) {
	row := r.db.QueryRowContext(ctx, "SELECT id, name, composer FROM songs WHERE id = $1", id)
	var song model.Song
	if err := row.Scan(&song.ID, &song.Name, &song.Composer); err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &song, nil
}

// Create creates a new song.
func (r *PostgresSongRepository) Create(ctx context.Context, song*model.Song) (*model.Song, error) {
	row := r.db.QueryRowContext(ctx, "INSERT INTO songs (id, name, composer) VALUES ($1, $2, $3) RETURNING id, name, composer", song.ID, song.Name, song.Composer)
	var newSong model.Song
	err := row.Scan(&newSong.ID, &newSong.Name, &newSong.Composer)
	if err != nil {
		return nil, err
	}
	return &newSong, nil
}

// Update updates an existing song.
func (r *PostgresSongRepository) Update(ctx context.Context, song*model.Song) (*model.Song, error) {
	row := r.db.QueryRowContext(ctx, "UPDATE songs SET name = $1, composer = $2 WHERE id = $3 RETURNING id, name, composer", song.Name, song.Composer, song.ID)
	var updatedSong model.Song
	err := row.Scan(&updatedSong.ID, &updatedSong.Name, &updatedSong.Composer)
	if err != nil {
		return nil, err
	}
	return &updatedSong, nil
}

// Delete deletes a song by ID.
func (r *PostgresSongRepository) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, "DELETE FROM songs WHERE id = $1", id)
	return err
}
{% endraw %}
{% endhighlight %}
</details><br>

Now let's say we want to test the Redis and PostgreSQL repositories. If we want the tests to simulate the actual data stores, we can use Testcontainers to spin up Redis and PostgreSQL containers before running the tests. This way, we can ensure that the tests are isolated and reproducible.

<details>
  <summary>repository/redis/redis_test.go</summary>
{% highlight go %}
{% raw %}
package repository

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"testing"

	"github.com/go-redis/redis/v8"
	"github.com/testcontainers/testcontainers-go"
	cr "github.com/testcontainers/testcontainers-go/modules/redis"
	"github.com/testcontainers/testcontainers-go/wait"
	"gotest.tools/v3/assert"

	"github.com/christosgalano/testcontainers-demo/model"
)

func setupTestRedisRepository(ctx context.Context) (*RedisSongRepository, func(), error) {
	// Start a Redis container
	container, err := cr.RunContainer(
		ctx,
		testcontainers.WithImage("redis:7"),
		cr.WithLogLevel(cr.LogLevelVerbose),
		testcontainers.WithWaitStrategy(wait.ForListeningPort("6379/tcp")),
	)
	if err != nil {
		return nil, nil, err
	}
	endpoint, err := container.Endpoint(ctx, "")
	if err != nil {
		return nil, nil, err
	}
	log.Printf("redis container endpoint: %s", endpoint)

	// Create a Redis client
	client := redis.NewClient(
		&redis.Options{
			Addr: endpoint,
		},
	)
	_, err = client.Ping(ctx).Result()
	if err != nil {
		return nil, nil, fmt.Errorf("failed to ping Redis: %w", err)
	}
	log.Printf("created redis client")

	// Create and a RedisSongRepository
	repo := &RedisSongRepository{client: client}
	log.Printf("created redis song repository")

	// Initialize the Redis store with test data
	initialSongs, err := os.ReadFile("./testdata/songs.json")
	if err != nil {
		return nil, nil, fmt.Errorf("failed to read songs.json: %w", err)
	}
	var songs []model.Song
	if err := json.Unmarshal(initialSongs, &songs); err != nil {
		return nil, nil, fmt.Errorf("failed to unmarshal songs: %w", err)
	}
	for _, s := range songs {
		song, err := json.Marshal(s)
		if err != nil {
			return nil, nil, fmt.Errorf("failed to marshal song: %w", err)
		}
		if err := client.Set(ctx, s.ID, song, 0).Err(); err != nil {
			return nil, nil, fmt.Errorf("failed to set song: %w", err)
		}
	}
	log.Printf("initialized redis store")

	// Return the repository and a cleanup function
	cleanup := func() {
		if err := container.Terminate(ctx); err != nil {
			log.Fatalf("failed to terminate container: %s", err)
		}
	}

	return repo, cleanup, nil
}

func TestRedisSongRepository_GetAll(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestRedisRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	songs, err := repo.GetAll(ctx)
	if err != nil {
		t.Fatalf("failed to get all songs: %s", err)
	}

	if len(songs) != 3 {
		t.Fatalf("expected 3 songs, got %d", len(songs))
	}

	expectedSongs := make(map[string]model.Song)
	for i := 1; i <= len(songs); i++ {
		expectedSongs[fmt.Sprintf("%d", i)] = model.Song{
			ID:       fmt.Sprintf("%d", i),
			Name:     fmt.Sprintf("Song %d", i),
			Composer: fmt.Sprintf("Composer %d", i),
		}
	}

	for _, s := range songs {
		expectedSong, ok := expectedSongs[s.ID]
		if !ok {
			t.Errorf("Unexpected song: %+v", s)
			continue
		}
		if s.Name != expectedSong.Name || s.Composer != expectedSong.Composer {
			t.Errorf("Expected song %+v, got %+v", expectedSong, s)
		}
	}
}

func TestRedisSongRepository_GetByID(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestRedisRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	song, err := repo.GetByID(ctx, "1")
	if err != nil {
		t.Fatalf("failed to get song by ID: %s", err)
	}

	expectedSong := model.Song{
		ID:       "1",
		Name:     "Song 1",
		Composer: "Composer 1",
	}
	assert.Equal(t, *song, expectedSong)

	nonExistentSong, err := repo.GetByID(ctx, "4")
	if err == nil {
		t.Fatalf("failed to return nil for non-existent song: %s", err)
	}
	assert.Equal(t, nonExistentSong, (*model.Song)(nil))
}

func TestRedisSongRepository_Create(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestRedisRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	song := &model.Song{
		ID:       "4",
		Name:     "Song 4",
		Composer: "Composer 4",
	}
	createdSong, err := repo.Create(ctx, song)
	if err != nil {
		t.Fatalf("failed to create song: %s", err)
	}

	assert.Equal(t, *createdSong, *song)
}

func TestRedisSongRepository_Update(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestRedisRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	song := &model.Song{
		ID:       "1",
		Name:     "Updated Song 1",
		Composer: "Updated Composer 1",
	}
	updatedSong, err := repo.Update(ctx, song)
	if err != nil {
		t.Fatalf("failed to update song: %s", err)
	}

	assert.Equal(t, *updatedSong, *song)
}

func TestRedisSongRepository_Delete(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestRedisRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	err = repo.Delete(ctx, "1")
	if err != nil {
		t.Fatalf("failed to delete song: %s", err)
	}

	song, err := repo.GetByID(ctx, "1")
	if err == nil {
		t.Fatalf("failed to return nil for deleted song: %s", err)
	}
	assert.Equal(t, song, (*model.Song)(nil))

	err = repo.Delete(ctx, "4")
	if err != nil {
		t.Fatalf("failed to delete non-existent song: %s", err)
	}
}
{% endraw %}
{% endhighlight %}
</details>

![test-redis](/assets/images/demos/testcontainers/test-redis.gif)<br>

<details>
  <summary>repository/postgres/postgres_test.go</summary>
{% highlight go %}
{% raw %}
package repository

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"path/filepath"
	"testing"
	"time"

	_ "github.com/lib/pq"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/modules/postgres"
	"github.com/testcontainers/testcontainers-go/wait"
	"gotest.tools/assert"

	"github.com/christosgalano/testcontainers-demo/model"
)

func setupTestPostgresRepository(ctx context.Context) (*PostgresSongRepository, func(), error) {
	username, password, database := "user", "password", "songs"

	// Start a PostgreSQL container
	container, err := postgres.RunContainer(
		ctx,
		testcontainers.WithImage("postgres:16"),
		postgres.WithDatabase(database),
		postgres.WithUsername(username),
		postgres.WithPassword(password),
		postgres.WithInitScripts(filepath.Join("testdata", "init-song-db.sql")),
		testcontainers.WithWaitStrategy(
			wait.ForLog("database system is ready to accept connections").
				WithOccurrence(2).
				WithStartupTimeout(5*time.Second),
		),
	)
	if err != nil {
		return nil, nil, err
	}
	endpoint, err := container.Endpoint(ctx, "")
	if err != nil {
		return nil, nil, err
	}
	log.Printf("postgres container endpoint: %s", endpoint)

	// Create a PostgreSQL client
	db, err := sql.Open("postgres", fmt.Sprintf(
		"postgresql://%s:%s@%s/%s?sslmode=disable",
		username, password, endpoint, database,
	))
	if err != nil {
		return nil, nil, fmt.Errorf("failed to open database: %w", err)
	}
	log.Printf("created postgres client")

	// Create and a PostgresSongRepository
	repo := &PostgresSongRepository{db: db}
	log.Printf("created postgres song repository")

	// Return the repository and a cleanup function
	cleanup := func() {
		if err := container.Terminate(ctx); err != nil {
			log.Fatalf("failed to terminate container: %s", err)
		}
	}

	return repo, cleanup, nil
}

func TestPostgresSongRepository_GetAll(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestPostgresRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	songs, err := repo.GetAll(ctx)
	if err != nil {
		t.Fatalf("failed to get all songs: %s", err)
	}

	if len(songs) != 3 {
		t.Fatalf("expected 3 songs, got %d", len(songs))
	}

	expectedSongs := make(map[string]model.Song)
	for i := 1; i <= len(songs); i++ {
		expectedSongs[fmt.Sprintf("%d", i)] = model.Song{
			ID:       fmt.Sprintf("%d", i),
			Name:     fmt.Sprintf("Song %d", i),
			Composer: fmt.Sprintf("Composer %d", i),
		}
	}

	for _, s := range songs {
		expectedSong, ok := expectedSongs[s.ID]
		if !ok {
			t.Errorf("Unexpected song: %+v", s)
			continue
		}
		if s.Name != expectedSong.Name || s.Composer != expectedSong.Composer {
			t.Errorf("Expected song %+v, got %+v", expectedSong, s)
		}
	}
}

func TestPostgresSongRepository_GetByID(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestPostgresRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	song, err := repo.GetByID(ctx, "1")
	if err != nil {
		t.Fatalf("failed to get song by ID: %s", err)
	}

	expectedSong := model.Song{
		ID:       "1",
		Name:     "Song 1",
		Composer: "Composer 1",
	}
	assert.Equal(t, *song, expectedSong)

	nonExistentSong, err := repo.GetByID(ctx, "4")
	if err != nil {
		t.Fatalf("failed to return nil for non-existent song: %s", err)
	}
	assert.Equal(t, nonExistentSong, (*model.Song)(nil))
}

func TestPostgresSongRepository_Create(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestPostgresRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	song := &model.Song{
		ID:       "4",
		Name:     "Song 4",
		Composer: "Composer 4",
	}
	createdSong, err := repo.Create(ctx, song)
	if err != nil {
		t.Fatalf("failed to create song: %s", err)
	}

	assert.Equal(t, *createdSong, *song)
}

func TestPostgresSongRepository_Update(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestPostgresRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	song := &model.Song{
		ID:       "1",
		Name:     "Updated Song 1",
		Composer: "Updated Composer 1",
	}
	updatedSong, err := repo.Update(ctx, song)
	if err != nil {
		t.Fatalf("failed to update song: %s", err)
	}

	assert.Equal(t, *updatedSong, *song)
}

func TestPostgresSongRepository_Delete(t *testing.T) {
	ctx := context.Background()

	repo, cleanup, err := setupTestPostgresRepository(ctx)
	if err != nil {
		t.Fatalf("failed to setup test: %s", err)
	}
	defer cleanup()

	err = repo.Delete(ctx, "1")
	if err != nil {
		t.Fatalf("failed to delete song: %s", err)
	}

	song, err := repo.GetByID(ctx, "1")
	if err != nil {
		t.Fatalf("failed to get song by ID: %s", err)
	}
	assert.Equal(t, song, (*model.Song)(nil))
}
{% endraw %}
{% endhighlight %}
</details>

![test-postgres](/assets/images/demos/testcontainers/test-postgres.gif)<br>

So, the general idea is to use Testcontainers to set up the necessary containers for your tests, interact with them, and then tear them down after the tests are complete. This approach ensures that your tests are isolated, reproducible, and consistent across different environments.

In the example above, we are using [modules](https://testcontainers.com/modules/) instead of creating a generic container. Modules provide a higher-level abstraction for common services like Redis, PostgreSQL, MySQL, etc., making it easier to set up and configure containers for testing.

If you need more control over the container setup, you can create a custom container using the `testcontainers.ContainerRequest` struct.

![test-general](/assets/images/demos/testcontainers/test-general.gif)

## Summary

Testcontainers is a versatile and powerful tool that brings the benefits of Docker to your testing environment. It provides isolated, reproducible, and easily managed test dependencies, helping to ensure that your tests are reliable and consistent. Whether you're testing databases, microservices, or third-party APIs, incorporating Testcontainers into your workflow can enhance the quality and robustness of your testing process. Try Testcontainers in your next project and experience the difference it can make in simplifying and improving your tests.

## Resources

- [**Testcontainers**](https://testcontainers.com/)
- [**GitHub Repository**](https://github.com/christosgalano/testcontainers-example)
