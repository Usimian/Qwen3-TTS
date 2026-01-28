# Step-by-Step Voice Cloning Guide

This guide will walk you through cloning a voice using Qwen3-TTS, from recording to generating speech.

---

## Option 1: Using the Web Interface (Easiest)

### Step 1: Start the Demo Server

Open a terminal and run:

```bash
cd /home/marc/Qwen3-TTS
source venv/bin/activate
qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base --no-flash-attn --port 8000
```

Wait for the message: "Running on local URL: http://0.0.0.0:8000"

### Step 2: Open the Web Interface

Open your web browser and go to:
```
http://localhost:8000
```

### Step 3: Record Your Reference Audio

You need 3-10 seconds of clear speech. Here are your recording options:

#### Option A: Record with Your Browser
1. In the web UI, look for "Reference Audio"
2. Click on the microphone icon
3. Allow browser to access your microphone
4. Click "Record" and speak clearly for 3-10 seconds
5. Click "Stop" when done
6. The audio will appear in the Reference Audio box

#### Option B: Record with Command Line (Linux)
Open a new terminal:

```bash
# Install recording tool if needed
sudo apt install alsa-utils

# Record 5 seconds of audio
arecord -d 5 -f cd -t wav ~/my_voice.wav

# Test playback
aplay ~/my_voice.wav
```

#### Option C: Record with Audacity
1. Open Audacity
2. Click the red record button
3. Speak for 3-10 seconds
4. Click stop
5. File → Export → Export as WAV
6. Save as `my_voice.wav`

### Step 4: Prepare Your Reference Text

Write down EXACTLY what you said in the recording. For example:
- If you said: "Hello, my name is John and I love programming."
- Your reference text should be: "Hello, my name is John and I love programming."

**Important:** The reference text should match the audio exactly, including punctuation.

### Step 5: Clone and Generate Speech

Now you have two methods:

---

## Method A: One-Time Voice Cloning (Quick Test)

Use this if you just want to test once.

### In the "Clone & Generate" Tab:

1. **Upload Reference Audio**
   - Click "Reference Audio"
   - Upload your `my_voice.wav` file (or use the recording from Step 3A)

2. **Enter Reference Text**
   - Type what was said in the audio
   - Example: "Hello, my name is John and I love programming."

3. **Leave "Use x-vector only" UNCHECKED**
   - This gives better quality
   - Only check this if you don't want to provide reference text (lower quality)

4. **Enter Target Text**
   - This is the NEW text you want the cloned voice to say
   - Example: "This is amazing! The voice cloning really works!"

5. **Select Language**
   - Choose "Auto" or your specific language

6. **Click "Generate"**
   - Wait 10-30 seconds (depending on text length)
   - The audio will appear in "Output Audio"
   - Click play to listen!

---

## Method B: Save Voice for Reuse (Recommended)

Use this if you want to reuse the same voice multiple times.

### Part 1: Save Your Voice Profile

1. **Go to the "Save / Load Voice" Tab**

2. **Under "Save Voice" section:**
   - **Upload Reference Audio:** Upload `my_voice.wav`
   - **Enter Reference Text:** Type what was said in the audio
   - **Leave "Use x-vector only" UNCHECKED**
   - **Click "Save Voice File"**
   - **Download the .pt file** that appears (e.g., `voice_clone_prompt_xxxxx.pt`)
   - Save it somewhere safe, like `~/my_voice_profile.pt`

### Part 2: Use Your Saved Voice

Now you can generate speech anytime without re-uploading audio:

1. **Under "Load Voice & Generate" section:**
   - **Upload Prompt File:** Upload your saved `.pt` file
   - **Enter Target Text:** Type what you want the voice to say
   - **Select Language:** Choose "Auto" or specific language
   - **Click "Generate"**
   - Listen to the output!

2. **Repeat Step 1 as many times as you want** with different text!

---

## Option 2: Using Python Code (Advanced)

If you prefer coding:

### One-Time Voice Cloning

```python
from qwen_tts import Qwen3TTSModel
import soundfile as sf

# Load the Base model
tts = Qwen3TTSModel.from_pretrained(
    "Qwen/Qwen3-TTS-12Hz-1.7B-Base",
    device_map="cuda:0",  # or "cpu" if no GPU
    dtype="bfloat16"
)

# Generate speech with voice cloning
wavs, sr = tts.generate_voice_clone(
    text="This is the new text I want the cloned voice to say.",
    language="Auto",
    ref_audio=("my_voice.wav",),  # Your reference audio file
    ref_text="Hello, my name is John and I love programming.",  # What was said in ref audio
    x_vector_only_mode=False  # False = better quality
)

# Save the output
sf.write("cloned_output.wav", wavs[0], sr)
print("Saved to cloned_output.wav")
```

### Save and Reuse Voice Profile

```python
from qwen_tts import Qwen3TTSModel
import soundfile as sf
import torch

# Load model
tts = Qwen3TTSModel.from_pretrained(
    "Qwen/Qwen3-TTS-12Hz-1.7B-Base",
    device_map="cuda:0",
    dtype="bfloat16"
)

# Step 1: Create voice profile (do this once)
voice_items = tts.create_voice_clone_prompt(
    ref_audio=("my_voice.wav",),
    ref_text="Hello, my name is John and I love programming.",
    x_vector_only_mode=False
)

# Save voice profile
payload = {"items": [vars(item) for item in voice_items]}
torch.save(payload, "my_voice_profile.pt")
print("Voice profile saved!")

# Step 2: Load and use voice profile (use many times)
payload = torch.load("my_voice_profile.pt", weights_only=True)

# Reconstruct voice items (you can skip this and use voice_items from Step 1)
from qwen_tts import VoiceClonePromptItem
loaded_items = []
for d in payload["items"]:
    loaded_items.append(VoiceClonePromptItem(
        ref_code=torch.tensor(d["ref_code"]) if d.get("ref_code") is not None else None,
        ref_spk_embedding=torch.tensor(d["ref_spk_embedding"]),
        x_vector_only_mode=d.get("x_vector_only_mode", False),
        icl_mode=d.get("icl_mode", True),
        ref_text=d.get("ref_text")
    ))

# Generate speech with saved voice
wavs, sr = tts.generate_voice_clone(
    text="This is a completely different sentence using my saved voice!",
    language="Auto",
    voice_clone_prompt=loaded_items
)

sf.write("output_from_saved_voice.wav", wavs[0], sr)
print("Generated speech from saved voice profile!")
```

---

## Tips for Best Results

### 1. **Reference Audio Quality**
   - **Duration:** 3-10 seconds is ideal
   - **Clarity:** Speak clearly, no background noise
   - **Single speaker:** Only one person talking
   - **Natural speech:** Don't read robotically, speak naturally

### 2. **Reference Text Accuracy**
   - Must match the audio EXACTLY
   - Include all punctuation
   - If you're not sure, just check "Use x-vector only" (but quality will be lower)

### 3. **Environment**
   - Record in a quiet room
   - Minimize echo (soft surfaces are better than hard walls)
   - Use a decent microphone if possible

### 4. **X-Vector Only Mode**
   **When to use it:**
   - You don't have a transcription of your audio
   - You want quick results

   **Trade-off:**
   - ✅ Easier (no need for reference text)
   - ❌ Lower quality voice cloning
   - ❌ Less natural sounding

   **Recommendation:** Always provide reference text for best quality!

---

## Troubleshooting

### "Reference audio is required"
**Fix:** Make sure you uploaded an audio file

### "Reference text is required when use x-vector only is NOT enabled"
**Fix:** Either:
- Provide the reference text, OR
- Check "Use x-vector only" checkbox

### Poor voice quality / doesn't sound like the voice
**Fixes:**
- Use LONGER reference audio (5-10 seconds)
- Make sure reference text EXACTLY matches the audio
- Use higher quality audio (less noise)
- DON'T use x-vector only mode
- Try recording multiple times and pick the clearest one

### Output audio sounds weird or broken
**Fixes:**
- Check your reference audio plays correctly
- Make sure reference text is accurate
- Try shorter target text first (one sentence)
- Verify the language setting is correct

### "Server not responding" or "Connection refused"
**Fix:**
```bash
# Make sure server is running
source venv/bin/activate
qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base --no-flash-attn --port 8000
```

---

## Quick Start Checklist

- [ ] Start demo server (or load model in Python)
- [ ] Record 3-10 seconds of clear speech
- [ ] Write down what was said (reference text)
- [ ] Upload reference audio to web UI
- [ ] Enter reference text
- [ ] Enter new text you want the voice to say
- [ ] Click Generate
- [ ] Listen to cloned voice!

---

## Example Session

Here's a complete example from start to finish:

### 1. Record audio
```bash
arecord -d 5 -f cd -t wav ~/my_voice.wav
# Speak: "Hello everyone, this is a test of voice cloning technology."
```

### 2. Start server
```bash
cd /home/marc/Qwen3-TTS
source venv/bin/activate
qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base --no-flash-attn --port 8000
```

### 3. In web browser (http://localhost:8000)
- Go to "Clone & Generate" tab
- Upload: `my_voice.wav`
- Reference Text: "Hello everyone, this is a test of voice cloning technology."
- Uncheck: "Use x-vector only"
- Target Text: "I can't believe how well this voice cloning works!"
- Click: "Generate"

### 4. Listen to result!
The output should sound like your voice saying the new text.

---

## Questions?

If you get stuck, check:
1. Is the server running? (should see "Running on local URL")
2. Can you access http://localhost:8000 in your browser?
3. Is your audio file valid? (try playing it with `aplay` or in browser)
4. Did you provide reference text? (or check x-vector only)

For more details, see `VOICE_CLONING_GUIDE.md`
