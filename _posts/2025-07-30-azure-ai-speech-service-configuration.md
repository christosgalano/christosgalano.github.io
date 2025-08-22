---
title: "Azure AI Speech Service Configuration"
excerpt: "Avoid common pitfalls when using Azure AI Speech with managed identity or API keys. Learn how to configure Speech-to-Text and Text-to-Speech across environments, including support for private endpoints."
tagline: "Make Azure AI Speech work across auth modes and network setups"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/azure/ai-speech/logo.webp
tags:
  - ai
  - azure
  - python
---

I was recently wiring up Azure AI Speech (for both TTS and STT) using managed identity and hit a few head-scratchers. It's classic integration stuff: "It works in one mode but breaks in another, and the docs don't quite say why."

So here's what I ran into and how I fixed it.

## Two gotchas to know

1. **Auth method matters.**  
   You can authenticate with a key or with managed identity. For the latter, your app needs the `Cognitive Services User` role, and the configuration changes depending on what you're doing (TTS vs. STT).

2. **Endpoint vs Region.**  
   If your Speech resource is behind a private endpoint, the region will not do; you need the full endpoint URL.

## What I wanted

I wanted a single utility function to figure out which mode I was in — key or identity — and create the right `SpeechConfig` object accordingly. Bonus: It should support both STT and TTS and work across environments.

Something like this:

{% highlight python %}
{% raw %}
# Just works with either auth method
speech_config = get_azure_speech_config()
{% endraw %}
{% endhighlight %}

## The fix

I built a set of helper functions that handle both authentication methods and configuration scenarios:

{% highlight python %}
{% raw %}
import os
from functools import lru_cache

import azure.cognitiveservices.speech as speechsdk
from azure.identity import DefaultAzureCredential

def refresh_azure_speech_token(cfg: speechsdk.SpeechConfig) -> None:
    """Refresh the authentication token for the Azure Speech service."""
    resource_id = os.getenv("SPEECH_RESOURCE_ID")
    if not resource_id:
        raise ValueError("Missing required env var: SPEECH_RESOURCE_ID")
    aad = (
        DefaultAzureCredential()
        .get_token("https://cognitiveservices.azure.com/.default")
        .token
    )
    cfg.authorization_token = f"aad#{resource_id}#{aad}"

def _build_azure_speech_config() -> speechsdk.SpeechConfig:
    """Build a SpeechConfig with shared auth + language setup."""
    endpoint = os.getenv("SPEECH_ENDPOINT")
    region = os.getenv("SPEECH_REGION")
    language = os.getenv("SPEECH_LANGUAGE", "en-US")
    key = os.getenv("SPEECH_KEY")

    if not key and not endpoint:
        raise ValueError("You must set SPEECH_ENDPOINT when using managed identity")

    # --- Auth & creation ---
    if key:
        if endpoint:
            cfg = speechsdk.SpeechConfig(endpoint=endpoint, subscription=key)
        else:
            cfg = speechsdk.SpeechConfig(subscription=key, region=region)
    else:
        cfg = speechsdk.SpeechConfig(endpoint=endpoint)
        refresh_azure_speech_token(cfg)

    cfg.speech_recognition_language = language
    cfg.speech_synthesis_language = language

    return cfg

@lru_cache(maxsize=1)
def get_azure_speech_config() -> speechsdk.SpeechConfig:
    """Singleton: SpeechConfig."""
    return _build_azure_speech_config()

def clear_azure_speech_caches() -> None:
    """Clear Azure Speech configuration."""
    get_azure_speech_config.cache_clear()
{% endraw %}
{% endhighlight %}

The solution consists of three main functions:

1. **`refresh_azure_speech_token()`** - Handles managed identity authentication by getting an Azure AD token and formatting it properly for the Speech service
2. **`_build_azure_speech_config()`** - The core logic that detects which authentication method to use based on available environment variables and creates the appropriate `SpeechConfig`
3. **`get_azure_speech_config()`** - A cached singleton wrapper that ensures we only build the configuration once

### Why the singleton approach?

The `@lru_cache(maxsize=1)` decorator makes `get_azure_speech_config()` a singleton: it's only called once per application lifecycle. This is useful because:

- **Performance**: Avoids recreating the `SpeechConfig` on every function call
- **Consistency**: Ensures the same configuration is used throughout your app
- **Token efficiency**: For managed identity, the initial token setup happens only once

The `clear_azure_speech_caches()` function lets you reset the cache if needed (useful for testing or configuration changes).

The authentication logic works as follows:
- **API key authentication**: Set `SPEECH_KEY` + either `SPEECH_REGION` or `SPEECH_ENDPOINT`
- **Managed identity authentication**: Set `SPEECH_RESOURCE_ID` + `SPEECH_ENDPOINT` (region alone won't work for managed identity)

| Environment Variable | Required | Description |
|---------------------|----------|-------------|
| `SPEECH_KEY` | For API key auth | Your Speech service subscription key |
| `SPEECH_REGION` | For regional endpoint | Azure region (e.g., "eastus") |
| `SPEECH_ENDPOINT` | For private/custom endpoint | Full endpoint URL (e.g., "https://your-speech-service.cognitiveservices.azure.com/") |
| `SPEECH_RESOURCE_ID` | For managed identity auth | Resource ID in format `/subscriptions/.../resourceGroups/.../providers/Microsoft.CognitiveServices/accounts/...` |
| `SPEECH_LANGUAGE` | Optional | Language code (defaults to "en-US") |
| `SPEECH_VOICE_NAME` | Optional | Voice name for TTS (defaults to "en-US-AvaNeural") |

> **NOTE**: If your Speech resource uses a private endpoint, you *must* use `SPEECH_ENDPOINT` instead of `SPEECH_REGION`.

## Example use cases

The helper functions make it easy to test both Text-to-Speech (TTS) and Speech-to-Text (STT). Here are two test functions that work entirely with files - no speakers or microphones needed (perfect for running on Azure VMs or CI/CD environments):

{% highlight python %}
{% raw %}
def test_text_to_speech_to_file() -> bool:
    print("\n=== Testing Text-to-Speech to WAV file only ===")
    try:
        speech_config = get_azure_speech_config()
        output_file = "test_speech_output.wav"
        audio_config = speechsdk.audio.AudioOutputConfig(filename=output_file)
        synthesizer = speechsdk.SpeechSynthesizer(
            speech_config=speech_config, audio_config=audio_config
        )
        text = "This is an Azure Speech Service connectivity test."
        print(f"Synthesizing text to file: '{output_file}' ...")
        result = synthesizer.speak_text_async(text).get()

        if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
            print(f"Text-to-speech completed, file: {output_file}")
            size = os.path.getsize(output_file)
            print(f"WAV file size: {size} bytes")
        elif result.reason == speechsdk.ResultReason.Canceled:
            cancel = result.cancellation_details
            print(f"Synthesis canceled: {cancel.reason}")
            if cancel.reason == speechsdk.CancellationReason.Error:
                print(f"Error details: {cancel.error_details}")
            return False
        return True
    except Exception as e:
        print(f"Text-to-speech to file failed: {e}")
        return False
{% endraw %}
{% endhighlight %}

This TTS test function:
- Uses `get_azure_speech_config()` to get the configured Speech service
- Creates an `AudioOutputConfig` that writes to a WAV file instead of speakers
- Synthesizes a test phrase and handles different result scenarios
- Returns `True`/`False` to indicate success or failure

{% highlight python %}
{% raw %}
def test_speech_to_text_from_file() -> bool:
    print("\n=== Testing Speech-to-Text from file ===")
    test_audio_file = "test_speech_output.wav"
    if not os.path.exists(test_audio_file) or os.path.getsize(test_audio_file) == 0:
        print("No valid wav file to transcribe (skipping test)")
        return False
    try:
        speech_config = get_azure_speech_config()
        audio_config = speechsdk.audio.AudioConfig(filename=test_audio_file)
        recognizer = speechsdk.SpeechRecognizer(
            speech_config=speech_config, audio_config=audio_config
        )
        print(f"Transcribing '{test_audio_file}' ...")
        result = recognizer.recognize_once_async().get()

        if result.reason == speechsdk.ResultReason.RecognizedSpeech:
            print(f"Speech recognized: '{result.text}'")
        elif result.reason == speechsdk.ResultReason.NoMatch:
            print("No speech could be recognized from the audio file")
        elif result.reason == speechsdk.ResultReason.Canceled:
            cancel = result.cancellation_details
            print(f"Recognition canceled: {cancel.reason}")
            if cancel.reason == speechsdk.CancellationReason.Error:
                print(f"Error details: {cancel.error_details}")
            return False
        return True
    except Exception as e:
        print(f"Speech-to-text from file failed: {e}")
        return False
{% endraw %}
{% endhighlight %}

This STT test function:
- Looks for the WAV file created by the TTS test
- Uses `AudioConfig(filename=...)` to read from the file instead of a microphone
- Handles the various recognition results including errors
- Can run on headless environments without audio hardware

## Using in production

When using this configuration in a production application (like an API service), you'll need to handle token expiration for managed identity scenarios. Azure AD tokens typically expire after 1 hour, so you should refresh them before making Speech service calls:

{% highlight python %}
{% raw %}
def my_api_speech_function():
    """Example API function that uses Speech service."""
    speech_config = get_azure_speech_config()

    # Refresh token if using managed identity
    if not os.getenv("SPEECH_KEY"):
        refresh_azure_speech_token(speech_config)
    
    # Now use the speech_config for TTS or STT...
    synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config)
    # ... rest of your logic
{% endraw %}
{% endhighlight %}

This pattern ensures that:
- **API key users**: Skip the token refresh (not needed)
- **Managed identity users**: Get a fresh token before each operation
- **Long-running apps**: Don't fail due to expired tokens

For high-frequency operations, you might want to implement a more sophisticated token caching strategy that only refreshes when the token is close to expiration.

## Common troubleshooting

Here are some issues you might encounter and their solutions:

**401 Unauthorized with managed identity:**
- Ensure your app has the `Cognitive Services User` role assigned
- Verify the `SPEECH_RESOURCE_ID` format is correct

**Connection timeouts with private endpoints:**
- Use `SPEECH_ENDPOINT` instead of `SPEECH_REGION`
- Ensure your app can reach the private endpoint (check network connectivity)
- Verify DNS resolution is working correctly

**Token expired errors in long-running apps:**
- Azure AD tokens expire after about 1 hour when using managed identity
- Call `refresh_azure_speech_token(speech_config)` before Speech operations
- Consider implementing token expiration checking for high-frequency apps

## Wrapping up

Azure AI Speech supports multiple auth methods and network configurations, but the combination isn't always evident from the docs. These helper functions handle the common scenarios in one place rather than scattered across your codebase:

- **Smart authentication detection** - Automatically chooses API key or managed identity based on available environment variables
- **Private endpoint support** - Handles both regional and custom endpoints
- **File-based testing** - Test functions that work without audio hardware
- **Caching for performance** - Singleton pattern ensures configuration is built only once

If you're working with Speech across different environments or auth setups, hopefully this saves you some troubleshooting time.
