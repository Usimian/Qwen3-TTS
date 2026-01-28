# Qwen3-TTS Quick Start Guide

## Three Ways to Choose Your Model

### Method 1: Edit .env File (Easiest)

Edit the `.env` file and change the MODEL value:

```bash
# For voice cloning (upload audio to clone voices)
MODEL=base

# For pre-defined speakers with emotion control
MODEL=customvoice

# For generating voices from text descriptions
MODEL=voicedesign

# For smaller/faster model
MODEL=small
```

Then start:
```bash
docker compose up
```

### Method 2: Command Line (No file editing)

```bash
# Voice cloning
MODEL=base docker compose up

# Pre-defined speakers
MODEL=customvoice docker compose up

# Voice design
MODEL=voicedesign docker compose up

# Smaller model
MODEL=small docker compose up
```

### Method 3: Export Environment Variable

```bash
# Set the model
export MODEL=base

# Start (will use the exported MODEL)
docker compose up

# Switch models
export MODEL=customvoice
docker compose restart
```

---

## Model Quick Reference

| MODEL Value | What It Does | When to Use |
|-------------|--------------|-------------|
| `base` | Voice cloning from audio | Upload 5s of your voice → speak in that voice |
| `customvoice` | 9 pre-built speakers + emotions | "Vivian, say this angrily" |
| `voicedesign` | Voice from text description | "Deep British male voice" |
| `small` | Faster, smaller model | Limited GPU memory |

---

## Complete Workflow Examples

### Example 1: Voice Cloning Workflow

```bash
# 1. Set model to base
echo "MODEL=base" > .env

# 2. Start container
docker compose up

# 3. Open browser
# http://localhost:8000

# 4. In "Clone & Generate" tab:
#    - Upload 5 seconds of audio
#    - Enter what was said (reference text)
#    - Enter new text to synthesize
#    - Click Generate
```

### Example 2: Switch Models

```bash
# Currently running customvoice, want to switch to base

# Stop container
docker compose down

# Edit .env file
echo "MODEL=base" > .env

# Start with new model
docker compose up
```

### Example 3: Try Different Models

```bash
# Try base model
MODEL=base docker compose up
# Ctrl+C to stop

# Try voicedesign model
MODEL=voicedesign docker compose up
# Ctrl+C to stop

# Try customvoice model
MODEL=customvoice docker compose up
```

---

## Common Commands

```bash
# Start (uses MODEL from .env file)
docker compose up

# Start in background
docker compose up -d

# Stop
docker compose down

# Restart (after changing .env)
docker compose restart

# View logs
docker compose logs -f

# Rebuild after code changes
docker compose build --no-cache && docker compose up
```

---

## Supported Audio Formats

When uploading audio for voice cloning:
- ✅ WAV (.wav) - Best quality
- ✅ FLAC (.flac) - Lossless
- ✅ MP3 (.mp3)
- ✅ OGG (.ogg)
- ✅ M4A (.m4a)

---

## Troubleshooting

### Wrong model is running
**Check:** Look at the web UI title - it shows which model is loaded
**Fix:**
1. Check `.env` file has correct MODEL value
2. Run `docker compose down` then `docker compose up`

### Out of memory
**Try:** Use `MODEL=small` (0.6B instead of 1.7B)

### Can't find audio input
**Check:** You need `MODEL=base` for voice cloning
**Other models:** CustomVoice and VoiceDesign don't have audio upload

### Changes not taking effect
**Solution:** Rebuild the image
```bash
docker compose down
docker compose build --no-cache
docker compose up
```

---

## Default Settings

If you don't specify a MODEL:
- Default is `base` (voice cloning)
- Set in `.env` file or via command line
- Can be changed anytime

---

## Next Steps

1. **Set your model** in `.env` (default is `base`)
2. **Start:** `docker compose up`
3. **Open:** http://localhost:8000
4. **For voice cloning guide:** See `STEP_BY_STEP_VOICE_CLONING.md`
5. **For detailed Docker info:** See `DOCKER_README.md`

That's it! No more editing YAML files or uncommenting lines.
