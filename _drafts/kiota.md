---
title: "Microsoft Kiota"
excerpt: "Kiota is a powerful tool designed to streamline the process of generating API clients for any OpenAPI-described API you're interested in."
tagline: "Simplifying API Client Generation"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/kiota/kiota.webp
tags:
  - go
  - miscellaneous
---

## Introduction

In today's interconnected digital world, APIs play a crucial role in enabling seamless communication between different software systems. However, working with various APIs often involves dealing with different SDKs, each with its own learning curve and dependencies. Enter Kiota - a powerful command-line tool designed to streamline the process of generating API clients for any OpenAPI-described API you're interested in.

## Understanding Kiota

Kiota aims to simplify the developer experience by providing a unified approach to API client generation. By leveraging the full capabilities of OpenAPI descriptions, Kiota generates strongly typed API clients in a variety of programming languages, including C#, CLI, Go, Java, PHP, Python, Ruby, Swift, and TypeScript. This flexibility ensures that developers can work with their preferred programming languages without sacrificing functionality.

## Key Features

- **Language Support:** Kiota supports a wide range of languages, enabling developers to work with familiar tools and frameworks.
- **OpenAPI Integration:** By fully leveraging OpenAPI descriptions, Kiota ensures accurate and comprehensive API client generation.
- **Low-Effort Implementation:** Kiota's architecture enables straightforward implementation of new language support, making it easy to adapt to evolving developer needs.
- **Minimal Dependencies:** Kiota minimizes external dependencies, ensuring lightweight and efficient API client generation.
- **IDE Autocomplete:** Generated code includes IDE autocomplete support, enhancing developer productivity and API resource discovery.
- **Full HTTP Capabilities:** Kiota provides full access to HTTP capabilities, empowering developers to interact with APIs seamlessly.

## Translator Example

To highlight Kiota's capabilities, let's walk through the process of generating a Go API client for a sample OpenAPI-described API.

First, ensure that you have the latest version of Kiota installed on your system. Information on installation and usage can be found in the [official Kiota documentation](https://learn.microsoft.com/en-us/openapi/kiota/install).

We are going to generate a client for the Star Wars API from [Fun Translations](https://funtranslations.com/starwars).

First, let's search for the specification of the API using the `kiota search` command and apisguru.

![kiota-search](/assets/images/kiota/kiota-search.gif)

This command searches for an OpenAPI description in multiple registries.

If we have the API specification, or we know the corresponding URL; we can run `kiota show` to display the API tree in a given description.

![kiota-show](/assets/images/kiota/kiota-show.gif)

Here, we can see the 6 different endpoints available in the Star Wars API.

Now it's time to generate the Go client using the `kiota generate` command.

{% highlight bash %}
{% raw %}
# Setup the project
mkdir translate-demo
cd translate-demo
mkdir translator

# Create Go module
touch main.go translator/translator.go
go mod init translate-demo

# Generate the client
kiota generate -l go -c TranslateClient -n client -d https://funtranslations.com/yaml/funtranslations.starwars.yaml -o ./client

# Install the required dependencies
go mod tidy
{% endraw %}
{% endhighlight %}

The `kiota generate` command generates a Go client for the Star Wars API using the provided OpenAPI description. The `-l` flag specifies the target language, `-c` specifies the client name, `-n` specifies the namespace, `-d` specifies the OpenAPI description URL, and `-o` specifies the output directory.

After running the command, the Go client is generated in the `client` directory.

![kiota-generate](/assets/images/kiota/kiota-generate.gif)

We could use the generated client directly, but instead lets create a simple Go package as a wrapper around it.

{% highlight go %}
{% raw %}
package translator

import (
	"context"
	"encoding/json"
	"log"

	"translate-demo/client"
	"translate-demo/client/translate"
)

// ApiResponse is a struct that defines the response from the funtranslations.com/starwars API.
type ApiResponse struct {
	Success struct {
		Total int `json:"total"`
	} `json:"success"`
	Contents struct {
		Translated  string `json:"translated"`
		Text        string `json:"text"`
		Translation string `json:"translation"`
	} `json:"contents"`
}

// Translator is an interface that defines the Translate method, which takes a string and returns a string and an error.
// Any struct that implements this interface can be used as a translator.
type Translator interface {
	Translate(text string) (string, error)
}

// YodaTranslator is a struct that implements the Translator interface.
// It's purpose is to translate text to Yoda using the funtranslations.com/starwars API.
type YodaTranslator struct {
	client *client.TranslateClient
}

func NewYodaTranslator(client *client.TranslateClient)*YodaTranslator {
	return &YodaTranslator{client: client}
}

func (t *YodaTranslator) Translate(text string) (string, error) {
	response, err := t.client.Translate().Yoda().Get(context.Background(), &translate.YodaRequestBuilderGetRequestConfiguration{
		QueryParameters: &translate.YodaRequestBuilderGetQueryParameters{
			Text: &text,
		},
	})
	if err != nil {
		log.Fatalf("Error translating text to Yoda: %v\n", err)
	}

	var apiResponse ApiResponse
	if err := json.Unmarshal(response, &apiResponse); err != nil {
		log.Fatalf("Error unmarshalling JSON: %v\n", err)
	}

	return apiResponse.Contents.Translated, nil
}

// SithTranslator is a struct that implements the Translator interface.
// It's purpose is to translate text to Sith using the funtranslations.com/starwars API.
type SithTranslator struct {
	client *client.TranslateClient
}

func NewSithTranslator(client *client.TranslateClient)*SithTranslator {
	return &SithTranslator{client: client}
}

func (t *SithTranslator) Translate(text string) (string, error) {
	response, err := t.client.Translate().Sith().Get(context.Background(), &translate.SithRequestBuilderGetRequestConfiguration{
		QueryParameters: &translate.SithRequestBuilderGetQueryParameters{
			Text: &text,
		},
	})
	if err != nil {
		log.Fatalf("Error translating text to Sith: %v\n", err)
	}

	var apiResponse ApiResponse
	if err := json.Unmarshal(response, &apiResponse); err != nil {
		log.Fatalf("Error unmarshalling JSON: %v\n", err)
	}

	return apiResponse.Contents.Translated, nil
}

// MandalorianTranslator is a struct that implements the Translator interface.
// It's purpose is to translate text to Mandalorian using the funtranslations.com/starwars API.
type MandalorianTranslator struct {
	client *client.TranslateClient
}

func NewMandalorianTranslator(client *client.TranslateClient)*MandalorianTranslator {
	return &MandalorianTranslator{client: client}
}

func (t *MandalorianTranslator) Translate(text string) (string, error) {
	response, err := t.client.Translate().Mandalorian().Get(context.Background(), &translate.MandalorianRequestBuilderGetRequestConfiguration{
		QueryParameters: &translate.MandalorianRequestBuilderGetQueryParameters{
			Text: &text,
		},
	})
	if err != nil {
		log.Fatalf("Error translating text to Mandalorian: %v\n", err)
	}

	var apiResponse ApiResponse
	if err := json.Unmarshal(response, &apiResponse); err != nil {
		log.Fatalf("Error unmarshalling JSON: %v\n", err)
	}

	return apiResponse.Contents.Translated, nil
}
{% endraw %}
{% endhighlight %}

The `translator` package contains three structs that implement the `Translator` interface. Each struct is responsible for translating text to a specific Star Wars language using the Fun Translations API.

Finally, let's create a simple Go program that uses the `translator` package to translate text to Yoda, Sith, and Mandalorian.

{% highlight go %}
{% raw %}
package main

import (
	"fmt"
	"log"

	auth "github.com/microsoft/kiota-abstractions-go/authentication"
	http "github.com/microsoft/kiota-http-go"

	"translate-demo/client"
	"translate-demo/translator"
)

func main() {
	// API requires no authentication, so use the anonymous
	// authentication provider
	authProvider := auth.AnonymousAuthenticationProvider{}

	// Create request adapter using the net/http-based implementation
	adapter, err := http.NewNetHttpRequestAdapter(&authProvider)
	if err != nil {
		log.Fatalf("Error creating request adapter: %v\n", err)
	}

	// Create the API client
	client := client.NewTranslateClient(adapter)

	// Text to translate
	text := "This generated SDK seems to be working!"
	fmt.Printf("\nInitial text: %s\n\n", text)

	// Create a YodaTranslator and translate the text
	yodaTranslator := translator.NewYodaTranslator(client)
	translatedText, err := yodaTranslator.Translate(text)
	if err != nil {
		log.Fatalf("Error translating text to Yoda: %v\n", err)
	}
	fmt.Printf("- Yoda translation: %s\n", translatedText)

	// Create a SithTranslator and translate the text
	sithTranslator := translator.NewSithTranslator(client)
	translatedText, err = sithTranslator.Translate(text)
	if err != nil {
		log.Fatalf("Error translating text to Sith: %v\n", err)
	}
	fmt.Printf("- Sith translation: %s\n", translatedText)

	// Create a MandalorianTranslator and translate the text
	mandalorianTranslator := translator.NewMandalorianTranslator(client)
	translatedText, err = mandalorianTranslator.Translate(text)
	if err != nil {
		log.Fatalf("Error translating text to Mandalorian: %v\n", err)
	}
	fmt.Printf("- Mandalorian translation: %s\n\n", translatedText)
}
{% endraw %}
{% endhighlight %}

The `main` function creates a new `TranslateClient` and uses it to create instances of the `YodaTranslator`, `SithTranslator`, and `MandalorianTranslator`. It then translates the given text to Yoda, Sith, and Mandalorian, respectively.

![go-run](/assets/images/kiota/go-run.gif)

NOTE: if you run the program multiple times in quick succession, you may encounter a `429 Too Many Requests` error. This is because the Fun Translations API has a rate limit.

## Summary

Kiota is a powerful tool that simplifies the process of generating API clients for OpenAPI-described APIs. By providing a unified approach to API client generation, Kiota enables developers to work with their preferred programming languages without sacrificing functionality. With its minimal dependencies, full HTTP capabilities, and IDE autocomplete support, Kiota is a valuable addition to any developer's toolkit.

## Resources

- [**Kiota Documentation**](https://learn.microsoft.com/en-us/openapi/kiota)
- [**Fun Translations API**](https://funtranslations.com/starwars)
- [**Samples Repository**](https://github.com/microsoft/kiota-samples/tree/main)
