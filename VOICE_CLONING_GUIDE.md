# Voice Cloning Guide for Qwen3-TTS

This guide explains how to record and use recordings to clone voices using the Qwen3-TTS Base model.

## Overview

Voice cloning is available in the **Base model** (`Qwen3-TTS-12Hz-1.7B-Base`). There are two ways to clone a voice:

1. **Clone & Generate** - Directly clone from a reference audio and generate speech in one step
2. **Save/Load Voice** - Save a voice profile for reuse across multiple generations

## Requirements

- **Model**: You must use the Base model variant
- **Reference Audio**: An audio file containing the voice you want to clone (WAV, MP3, etc.)
- **Reference Text** (optional): The transcription of what's being said in the reference audio

## Method 1: Clone & Generate (One-Time Use)

This method clones a voice and generates speech in a single operation.

### Steps:

1. **Start the demo with the Base model:**
   ```bash
   qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base
   ```

2. **In the web UI, go to the "Clone & Generate" tab**

3. **Upload your reference audio:**
   - Click on "Reference Audio" and upload your audio file
   - Supported formats: WAV, MP3, FLAC, etc.
   - Recommended: 3-10 seconds of clear speech

4. **Choose your cloning mode:**

   **Option A: Full ICL Mode (Recommended - Better Quality)**
   - Provide the "Reference Text" (transcription of the reference audio)
   - Leave "Use x-vector only" unchecked
   - This gives the best cloning quality

   **Option B: X-Vector Only Mode (Simpler - Lower Quality)**
   - Check "Use x-vector only"
   - No reference text needed
   - Quality is limited but simpler to use

5. **Enter your target text:**
   - Type the text you want the cloned voice to speak

6. **Select language:**
   - Choose "Auto" or your specific language

7. **Click "Generate"**

### Example Code:

```python
from qwen_tts import Qwen3TTSModel
import soundfile as sf

# Load the Base model
tts = Qwen3TTSModel.from_pretrained(
    "Qwen/Qwen3-TTS-12Hz-1.7B-Base",
    device_map="cuda:0",
    dtype="bfloat16"
)

# Method 1: Full ICL mode (with reference text)
wavs, sr = tts.generate_voice_clone(
    text="Hello, this is a cloned voice speaking.",
    language="Auto",
    ref_audio=("reference_audio.wav",),  # Path to your reference audio
    ref_text="This is what was said in the reference audio.",
    x_vector_only_mode=False
)

# Method 2: X-vector only mode (no reference text needed)
wavs, sr = tts.generate_voice_clone(
    text="Hello, this is a cloned voice speaking.",
    language="Auto",
    ref_audio=("reference_audio.wav",),
    x_vector_only_mode=True
)

# Save the output
sf.write("output.wav", wavs[0], sr)
```

## Method 2: Save/Load Voice (Reusable Voice Profiles)

This method saves a voice profile that can be reused multiple times without re-uploading the reference audio.

### Steps to Save a Voice:

1. **Go to the "Save / Load Voice" tab**

2. **Under "Save Voice" section:**
   - Upload your reference audio
   - Provide reference text (if not using x-vector only)
   - Check/uncheck "Use x-vector only" based on your preference
   - Click "Save Voice File"

3. **Download the voice file:**
   - A `.pt` file will be generated
   - Download and save it for future use

### Steps to Use a Saved Voice:

1. **Under "Load Voice & Generate" section:**
   - Upload your saved `.pt` voice file
   - Enter the text you want to synthesize
   - Select language
   - Click "Generate"

### Example Code:

```python
from qwen_tts import Qwen3TTSModel
import soundfile as sf

tts = Qwen3TTSModel.from_pretrained(
    "Qwen/Qwen3-TTS-12Hz-1.7B-Base",
    device_map="cuda:0"
)

# Step 1: Create a reusable voice prompt
voice_items = tts.create_voice_clone_prompt(
    ref_audio=("reference_audio.wav",),
    ref_text="This is the reference text.",
    x_vector_only_mode=False
)

# Save the voice prompt for later use
import torch
torch.save({"items": [item.__dict__ for item in voice_items]}, "my_voice.pt")

# Step 2: Load and use the saved voice prompt
payload = torch.load("my_voice.pt", weights_only=True)
# ... (reconstruction code - see demo.py lines 526-563 for details)

# Generate speech with the saved voice
wavs, sr = tts.generate_voice_clone(
    text="This is new text using the saved voice.",
    language="Auto",
    voice_clone_prompt=voice_items
)

sf.write("output.wav", wavs[0], sr)
```

## Tips for Best Results

1. **Reference Audio Quality:**
   - Use clear, high-quality audio
   - Minimize background noise
   - 3-10 seconds of speech is ideal
   - Single speaker only

2. **Reference Text Accuracy:**
   - Provide accurate transcription when using ICL mode
   - Match punctuation and capitalization if possible
   - Transcription improves voice quality significantly

3. **Choosing Between Modes:**
   - **ICL Mode** (with reference text): Best quality, requires transcription
   - **X-Vector Only**: Quick and simple, but lower quality

4. **Multiple References:**
   - You can provide multiple reference audio clips for better quality
   - The model will combine information from all references

## Recording Your Own Voice

To record audio for voice cloning:

1. **Recording Software:**
   - Linux: Audacity, GNOME Sound Recorder, `arecord`
   - Windows: Audacity, Voice Recorder
   - Mac: QuickTime, GarageBand

2. **Recording Settings:**
   - Sample rate: 16kHz or higher (model accepts various rates)
   - Format: WAV (preferred) or MP3
   - Duration: 3-10 seconds of clear speech
   - Environment: Quiet room, minimal echo

3. **Command Line Recording (Linux):**
   ```bash
   # Record 10 seconds of audio
   arecord -d 10 -f cd -t wav reference_audio.wav

   # Or use ffmpeg
   ffmpeg -f alsa -i default -t 10 reference_audio.wav
   ```

## Model Types Comparison

| Model Type | Use Case | Voice Control |
|------------|----------|---------------|
| **CustomVoice** | Pre-defined speakers with emotion control | Choose from built-in speakers + instructions |
| **VoiceDesign** | Natural language voice description | Describe voice characteristics in text |
| **Base** | Voice cloning from audio | Upload your own reference audio |

## Troubleshooting

**"Reference audio is required"**
- Make sure you've uploaded an audio file

**"Reference text is required when use x-vector only is NOT enabled"**
- Either provide the reference text OR check "Use x-vector only"

**Poor voice quality:**
- Try providing reference text instead of x-vector only mode
- Use higher quality reference audio
- Ensure reference audio is 3-10 seconds long

**"Invalid file format"**
- When loading saved voices, ensure the file is a valid `.pt` file created by the system

## Additional Resources

- See `examples/test_model_12hz_base.py` for more code examples
- Check the main README.md for general model information
- API documentation: Use `help(Qwen3TTSModel.generate_voice_clone)`
