# Running Qwen3-TTS with Docker - Complete Guide

## Quick Answer: How to Run Each Model Type

### For Voice Cloning (Upload Audio):
```bash
# Edit docker-compose.yml, uncomment this line:
# command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base --ip 0.0.0.0 --port 8000 --no-flash-attn

docker compose up
# Access: http://localhost:8000
```

### For Pre-defined Speakers with Emotions:
```bash
# Edit docker-compose.yml, uncomment this line:
# command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice --ip 0.0.0.0 --port 8000 --no-flash-attn

docker compose up
# Access: http://localhost:8000
```

### For Voice Design from Text:
```bash
# Edit docker-compose.yml, uncomment this line:
# command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign --ip 0.0.0.0 --port 8000 --no-flash-attn

docker compose up
# Access: http://localhost:8000
```

---

## Model Comparison

| Model | What It Does | Example |
|-------|--------------|---------|
| **Base** | Clone voices from audio recordings | Upload 5 seconds of your voice → Generate speech in that voice |
| **CustomVoice** | Use 9 pre-built voices with emotion control | "Vivian, say this in an angry tone" |
| **VoiceDesign** | Create voices from text descriptions | "A deep British male voice with enthusiasm" |
| **0.6B-CustomVoice** | Smaller/faster version (no emotion control) | Pre-defined speakers, less GPU memory |

---

## Detailed Instructions

### Step 1: Edit docker-compose.yml

Open `docker-compose.yml` and find these lines (around line 20):

```yaml
# Override the default model by uncommenting one of these:
# command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice --ip 0.0.0.0 --port 8000 --no-flash-attn
# command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign --ip 0.0.0.0 --port 8000 --no-flash-attn
# command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base --ip 0.0.0.0 --port 8000 --no-flash-attn
# command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice --ip 0.0.0.0 --port 8000 --no-flash-attn
```

**Uncomment** the model you want by removing the `#` at the beginning.

**Example for voice cloning:**
```yaml
command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base --ip 0.0.0.0 --port 8000 --no-flash-attn
```

### Step 2: Start the Container

```bash
docker compose up
```

Wait for:
- Model download (first time only, 3-4GB)
- "Running on http://0.0.0.0:8000" message

### Step 3: Access the Web UI

Open your browser to: **http://localhost:8000**

### Step 4: To Switch Models

```bash
# Stop the current container
docker compose down

# Edit docker-compose.yml and uncomment a different model

# Start again
docker compose up
```

---

## Advanced: Run All Three Models at Once

If you have enough GPU memory (~12-16GB VRAM), you can run all models simultaneously on different ports.

Create `docker-compose-all.yml`:

```yaml
services:
  qwen3-tts-base:
    build: .
    image: qwen3-tts:latest
    container_name: qwen3-tts-base
    ports:
      - "8000:8000"
    volumes:
      - huggingface-cache:/root/.cache/huggingface
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
    command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base --ip 0.0.0.0 --port 8000 --no-flash-attn

  qwen3-tts-customvoice:
    build: .
    image: qwen3-tts:latest
    container_name: qwen3-tts-customvoice
    ports:
      - "8001:8000"
    volumes:
      - huggingface-cache:/root/.cache/huggingface
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
    command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice --ip 0.0.0.0 --port 8000 --no-flash-attn

  qwen3-tts-voicedesign:
    build: .
    image: qwen3-tts:latest
    container_name: qwen3-tts-voicedesign
    ports:
      - "8002:8000"
    volumes:
      - huggingface-cache:/root/.cache/huggingface
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
    command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign --ip 0.0.0.0 --port 8000 --no-flash-attn

volumes:
  huggingface-cache:
```

**Run all three:**
```bash
docker compose -f docker-compose-all.yml up
```

**Access:**
- **Voice Cloning (Base):** http://localhost:8000
- **Pre-defined Speakers (CustomVoice):** http://localhost:8001
- **Voice Design:** http://localhost:8002

---

## Common Commands

```bash
# Start container
docker compose up

# Start in background (detached)
docker compose up -d

# Stop container
docker compose down

# View logs
docker compose logs -f

# Rebuild after code changes
docker compose build --no-cache

# Restart
docker compose restart

# Check status
docker ps
```

---

## Recommended Model for Voice Cloning

Based on your questions about recording and cloning voices, you want the **Base** model:

1. **Edit `docker-compose.yml`** (line ~23):
   ```yaml
   command: qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base --ip 0.0.0.0 --port 8000 --no-flash-attn
   ```

2. **Start:**
   ```bash
   docker compose up
   ```

3. **Open:** http://localhost:8000

4. **You'll see two tabs:**
   - **"Clone & Generate"** - One-time voice cloning
   - **"Save / Load Voice"** - Save voices for reuse

5. **Follow the guide:** See `STEP_BY_STEP_VOICE_CLONING.md`

---

## Audio Format Support

The web UI accepts these audio formats when you upload:
- ✅ **WAV** (.wav) - Recommended
- ✅ **FLAC** (.flac) - Lossless
- ✅ **MP3** (.mp3) - Compressed
- ✅ **OGG** (.ogg) - Compressed
- ✅ **M4A** (.m4a) - AAC format

**Best quality:** Use WAV or FLAC files

---

## Troubleshooting

### Out of Memory / OOM Errors
**Problem:** GPU runs out of memory
**Solutions:**
- Use the smaller 0.6B model: `Qwen3-TTS-12Hz-0.6B-CustomVoice`
- Run only one model at a time
- Close other GPU applications

### Can't Access the Web UI
**Problem:** Browser shows "can't connect"
**Check:**
```bash
# Is the container running?
docker ps

# View logs for errors
docker compose logs

# Is port 8000 already in use?
sudo netstat -tlnp | grep 8000
```

### Chinese Characters Still Appear
**Problem:** UI shows Chinese text
**Solution:** Rebuild the Docker image:
```bash
docker compose down
docker compose build --no-cache
docker compose up
```

### Model Download is Slow
**First run:** Models download 3-4GB (takes time)
**Subsequent runs:** Models are cached (much faster)

The cache is stored in Docker volume `huggingface-cache`

### "No Audio Input" in UI
**Problem:** Can't upload audio for voice cloning
**Cause:** You're using CustomVoice or VoiceDesign model
**Solution:** Switch to **Base** model in docker-compose.yml

---

## What You Need to Know

### GPU Memory Requirements
- **0.6B models:** ~4-6GB VRAM
- **1.7B models:** ~8-10GB VRAM
- **All three 1.7B models together:** ~16-20GB VRAM

### First Run vs Subsequent Runs
- **First run:** Downloads model (~3-4GB), takes 5-15 minutes
- **Second run:** Uses cached model, starts in 30-60 seconds

### Port Configuration
- Default: Container uses port 8000
- Change in docker-compose.yml: `"YOUR_PORT:8000"`
- Example: `"7000:8000"` → Access at http://localhost:7000

---

## Quick Reference

| What I Want | Model to Use | docker-compose.yml Command |
|-------------|--------------|----------------------------|
| Clone my voice from recording | Base | `Qwen3-TTS-12Hz-1.7B-Base` |
| Use built-in voices with emotions | CustomVoice | `Qwen3-TTS-12Hz-1.7B-CustomVoice` |
| Describe voice in text | VoiceDesign | `Qwen3-TTS-12Hz-1.7B-VoiceDesign` |
| Fastest/smallest model | 0.6B-CustomVoice | `Qwen3-TTS-12Hz-0.6B-CustomVoice` |

---

## Next Steps

1. **Choose your model** and uncomment it in `docker-compose.yml`
2. **Run:** `docker compose up`
3. **Open:** http://localhost:8000
4. **For voice cloning guide:** Read `STEP_BY_STEP_VOICE_CLONING.md`

That's it! The UI is now fully in English with no Chinese characters.
