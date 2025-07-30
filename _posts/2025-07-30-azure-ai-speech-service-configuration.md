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
speech_config = create_speech_config("tts")  # or "stt"
{% endraw %}
{% endhighlight %}

## The fix

So I built a small helper:  

{% highlight python %}
{% raw %}
import os
import logging

import azure.cognitiveservices.speech as speechsdk
from azure.identity import DefaultAzureCredential

def create_speech_config(scenario: str) -> speechsdk.SpeechConfig:
    """
    Creates an Azure SpeechConfig object based on environment variables and authentication scenario.

    Supported scenarios:
      - "stt" (Speech-to-Text): Uses either subscription key or managed identity token
      - "tts" (Text-to-Speech): Uses either subscription key or AAD token via managed identity

    Required ENV VARS:
      - SPEECH_LANGUAGE           (optional, defaults to "en-US")
      - SPEECH_KEY                (if using API key auth)
      - SPEECH_REGION             (if using regional endpoint)
      - SPEECH_ENDPOINT           (if using custom/private endpoint)
      - SPEECH_RESOURCE_ID        (required for TTS with AAD token)

    Falls back to DefaultAzureCredential for managed identity.
    """
    # --- Env setup ---
    endpoint = os.getenv("SPEECH_ENDPOINT")
    language = os.getenv("SPEECH_LANGUAGE", "en-US")
    voice_name = os.getenv("SPEECH_VOICE_NAME", "en-US-AvaNeural")
    region = os.getenv("SPEECH_REGION")
    resource_id = os.getenv("SPEECH_RESOURCE_ID")
    key = os.getenv("SPEECH_KEY")
    cred = DefaultAzureCredential()

    # --- Validation ---
    if not endpoint and not region:
        raise ValueError("You must set either SPEECH_ENDPOINT or SPEECH_REGION")

    if not key and scenario == "tts" and not resource_id:
        raise ValueError(
            "SPEECH_RESOURCE_ID must be set for TTS using managed identity"
        )

    # --- Auth logic ---
    if key:
        logging.info("Using Azure AI Speech with API key")
        if endpoint:
            cfg = speechsdk.SpeechConfig(endpoint=endpoint, subscription=key)
        else:
            cfg = speechsdk.SpeechConfig(subscription=key, region=region)

    else:
        logging.info("Using Azure AI Speech with Managed Identity")
        if scenario == "stt":
            if endpoint:
                cfg = speechsdk.SpeechConfig(endpoint=endpoint, token_credential=cred)
            else:
                cfg = speechsdk.SpeechConfig(region=region, token_credential=cred)

        elif scenario == "tts":
            aad_token = cred.get_token(
                "https://cognitiveservices.azure.com/.default"
            ).token
            auth_token = f"aad#{resource_id}#{aad_token}"
            if endpoint:
                cfg = speechsdk.SpeechConfig(endpoint=endpoint)
            else:
                cfg = speechsdk.SpeechConfig(region=region)
            cfg.authorization_token = auth_token

        else:
            raise ValueError(f"Unknown scenario: {scenario}. Must be 'stt' or 'tts'")

    # --- Apply shared config ---
    cfg.speech_recognition_language = language
    cfg.speech_synthesis_language = language
    cfg.speech_synthesis_voice_name = voice_name

    return cfg
{% endraw %}
{% endhighlight %}

It reads from environment variables and returns the corresponding `SpeechConfig`.

If you're using:
- **API key authentication**: Set `SPEECH_KEY` + either `SPEECH_REGION` or `SPEECH_ENDPOINT`
- **Managed identity authentication**: Set `SPEECH_RESOURCE_ID` + either `SPEECH_REGION` or `SPEECH_ENDPOINT`

| Environment Variable | Required | Description |
|---------------------|----------|-------------|
| `SPEECH_KEY` | For API key auth | Your Speech service subscription key |
| `SPEECH_REGION` | For regional endpoint | Azure region (e.g., "eastus") |
| `SPEECH_ENDPOINT` | For private/custom endpoint | Full endpoint URL (e.g., "https://your-speech-service.cognitiveservices.azure.com/") |
| `SPEECH_RESOURCE_ID` | For TTS with managed identity | Resource ID in format `/subscriptions/.../resourceGroups/.../providers/Microsoft.CognitiveServices/accounts/...` |
| `SPEECH_LANGUAGE` | Optional | Language code (defaults to "en-US") |
| `SPEECH_VOICE_NAME` | Optional | Voice name for TTS (defaults to "en-US-AvaNeural") |

> **NOTE**: If your Speech resource uses a private endpoint, you *must* use `SPEECH_ENDPOINT` instead of `SPEECH_REGION`.

## Example use cases

Using this helper, I wanted to test both Text-to-Speech (TTS) and Speech-to-Text (STT). Here's how I did it in a way so that I don't rely on speakers or microphones, just files (to support running on Azure virtual machines):

{% highlight python %}
{% raw %}
def test_text_to_speech_to_file() -> bool:
    print("\n=== Testing Text-to-Speech to WAV file only ===")
    try:
        speech_config = create_speech_config("tts")
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

{% highlight python %}
{% raw %}
def test_speech_to_text_from_file() -> bool:
    print("\n=== Testing Speech-to-Text from file ===")
    test_audio_file = "test_speech_output.wav"
    if not os.path.exists(test_audio_file) or os.path.getsize(test_audio_file) == 0:
        print("No valid wav file to transcribe (skipping test)")
        return False
    try:
        speech_config = create_speech_config("stt")
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

Both rely on `create_speech_config()` to abstract away the auth + endpoint dance.

## Common troubleshooting

Here are some issues you might encounter and their solutions:

**401 Unauthorized with managed identity:**
- Ensure your app has the `Cognitive Services User` role assigned
- Verify the `SPEECH_RESOURCE_ID` format is correct

**Connection timeouts with private endpoints:**
- Use `SPEECH_ENDPOINT` instead of `SPEECH_REGION`
- Ensure your app can reach the private endpoint (check network connectivity)
- Verify DNS resolution is working correctly

**TTS fails but STT works (or vice versa):**
- Different auth flows for TTS vs STT with managed identity
- TTS requires the `SPEECH_RESOURCE_ID` environment variable
- Check that your managed identity has the right permissions

## Wrapping up

Azure AI Speech supports multiple auth methods and network configurations, but the combination isn't always evident from the docs. This helper function handles the common scenarios in one place rather than scattered across your codebase.

If you're working with Speech across different environments or auth setups, hopefully this saves you some troubleshooting time.
