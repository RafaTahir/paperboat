"""AFTER THE RAIN: deterministic original score and sound design.

Run with Python 3.12+, NumPy and soundfile. No sampled recordings or third-party
musical material. A 16-bar, 72 BPM D-pentatonic miniature, with three aligned
53.333-second stems. Acoustic character and room tails are rendered into files.
"""
from pathlib import Path
import json
import sys
import numpy as np

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE / ".audio-tools"))
import soundfile as sf

OUT = HERE.parent / "assets" / "audio"
OUT.mkdir(parents=True, exist_ok=True)
SR = 24000
BEAT = 60 / 72
LOOP = BEAT * 64
RNG = np.random.default_rng(171126)
REPORT = {}


def hz(midi):
    return 440 * 2 ** ((midi - 69) / 12)


def noise(seconds, cutoff=1400, lowcut=35):
    count = int(seconds * SR)
    x = RNG.normal(0, 1, count)
    freqs = np.fft.rfftfreq(count, 1 / SR)
    filt = 1 / np.sqrt(1 + (freqs / cutoff) ** 6)
    filt *= freqs / np.maximum(freqs + lowcut, 1)
    y = np.fft.irfft(np.fft.rfft(x) * filt, n=count)
    return y / max(np.std(y), 1e-6)


def stereo(x, pan=0):
    return np.stack((x * np.sqrt((1 - pan) / 2), x * np.sqrt((1 + pan) / 2)), axis=1)


def add(buf, x, when, pan=0, gain=1, wrap=False):
    x = stereo(x, pan) * gain if x.ndim == 1 else x * gain
    first = int(when * SR)
    if wrap:
        for offset in range(0, len(x), len(buf)):
            part = x[offset:offset + len(buf)]
            inds = (np.arange(len(part)) + first + offset) % len(buf)
            buf[inds] += part
    else:
        first = max(0, first)
        count = min(len(x), len(buf) - first)
        if count > 0:
            buf[first:first + count] += x[:count]


def note(midi, seconds=3.5, voice="pluck"):
    t = np.arange(int(seconds * SR)) / SR
    f = hz(midi)
    if voice == "pad":
        env = (1 - np.exp(-t * 2.5)) * np.minimum(1, (seconds - t) / 1.5)
        env *= np.exp(-t * .11)
        x = np.sin(2 * np.pi * f * t + .006 * np.sin(t * 3.1))
        x += .20 * np.sin(2 * np.pi * f * 2.001 * t)
        x += .06 * np.sin(2 * np.pi * f * 3 * t)
    elif voice == "bell":
        env = (1 - np.exp(-t * 150)) * np.exp(-t * 1.4)
        x = np.sin(2 * np.pi * f * t)
        x += .27 * np.sin(2 * np.pi * f * 2.008 * t) * np.exp(-t * .6)
        x += .07 * np.sin(2 * np.pi * f * 3.99 * t) * np.exp(-t * 1.1)
    else:
        env = (1 - np.exp(-t * 230)) * np.exp(-t * 1.9)
        x = np.sin(2 * np.pi * f * t)
        x += .28 * np.sin(2 * np.pi * f * 2 * t) * np.exp(-t * 1.7)
        x += .12 * np.sin(2 * np.pi * f * 3.001 * t) * np.exp(-t * 3.1)
        x += .05 * noise(seconds, 1800) * np.exp(-t * 35)
    return x * env


def room(x, loop=False):
    y = x.copy()
    for delay, gain in ((.117,.13),(.229,.11),(.373,.085),(.571,.065),(.839,.045), (1.117,.028)):
        n = int(delay * SR)
        shifted = np.roll(x[:, ::-1], n, axis=0)
        if not loop:
            shifted[:n] = 0
        y += shifted * gain
    return y


def save(name, x, peak=.3, loop=False):
    if x.ndim == 1:
        x = stereo(x)
    x -= np.mean(x, axis=0)
    highest = np.max(np.abs(x))
    if highest > 0:
        x *= peak / highest
    if not loop:
        fade = min(int(.018 * SR), len(x) // 4)
        x[:fade] *= np.linspace(0, 1, fade)[:, None]
        x[-fade:] *= np.linspace(1, 0, fade)[:, None]
    path = OUT / (name + ".ogg")
    # Small writes avoid a Windows libsndfile/Vorbis stack limit on long buffers.
    with sf.SoundFile(path, "w", samplerate=SR, channels=2, format="OGG", subtype="VORBIS") as output:
        for first in range(0, len(x), 8192):
            output.write(x[first:first + 8192].astype(np.float32))
    REPORT[name] = {"seconds": round(len(x) / SR, 6), "sample_rate": SR,
                    "channels": 2, "peak_dbfs": round(float(20 * np.log10(max(np.max(np.abs(x)), 1e-9))), 2),
                    "rms_dbfs": round(float(20 * np.log10(max(np.sqrt(np.mean(x*x)), 1e-9))), 2),
                    "bytes": path.stat().st_size, "loop": loop}


def score():
    count = round(LOOP * SR)
    calm = np.zeros((count, 2))
    motion = np.zeros_like(calm)
    arrival = np.zeros_like(calm)
    # Four four-bar harmonies; all phrase and timing data is authored here.
    chords = [(50,57,61,66,69), (47,54,57,62,66), (43,50,57,59,66), (45,52,57,59,64)]
    for block, chord in enumerate(chords):
        for index, midi in enumerate(chord):
            add(calm, note(midi, 16 * BEAT + 2, "pad"), block * 16 * BEAT + index * .025,
                pan=(index - 2) * .19, gain=.11 if index else .15, wrap=True)
        for beat in range(16):
            midi = chord[[1,2,3,2,1,4,3,2][beat % 8]] + (12 if beat % 4 == 3 else 0)
            add(motion, note(midi, 3), (block * 16 + beat + .08) * BEAT,
                pan=.24 * (-1 if beat % 2 else 1), gain=.11 if beat % 4 else .15, wrap=True)
    # Spacious, asymmetric pentatonic melody. Rests carry the miniature scale.
    melody = [(1,74),(4.5,78),(7,81),(11,78),(14,76),
              (18,74),(21,71),(24.5,69),(28,74),
              (33,78),(36,81),(39.5,83),(43,81),(46,78),
              (49,76),(52,74),(56,69),(59,74)]
    for index, (beat, midi) in enumerate(melody):
        add(arrival, note(midi, 5.4, "bell"), beat * BEAT,
            pan=np.sin(index * 1.9) * .3, gain=.3, wrap=True)
    save("music_calm", room(calm, True), .28, True)
    save("music_motion", room(motion, True), .26, True)
    save("music_arrival", room(arrival, True), .3, True)


def drop(seconds=.42, freq=1200):
    t = np.arange(int(seconds * SR)) / SR
    phase = 2 * np.pi * (freq * t - freq * .65 * (1 - np.exp(-t * 22)) / 22)
    return np.sin(phase) * np.exp(-t * 24) * (1 - np.exp(-t * 800)) + noise(seconds, 2200) * np.exp(-t * 65) * .11


def effects():
    duration = 48
    t = np.arange(SR * duration) / SR
    amb = stereo(noise(duration, 450), -.25) * .018
    amb += stereo(noise(duration, 1600), .3) * .008
    amb *= (.7 + .16 * np.sin(t * .29) + .14 * np.sin(t * .13))[:, None]
    for when in [2.1, 7.6, 12.4, 21.7, 28.8, 34.4, 44.2]:
        add(amb, drop(freq=900 + RNG.random() * 550), when, RNG.uniform(-.8,.8), .06, True)
    save("courtyard_ambience", room(amb, True), .13, True)
    t = np.arange(SR * 12) / SR
    lap = noise(12, 850) * (.35 + .35 * np.sin(t * 2.1)**2) + .22 * noise(12, 2600) * np.sin(t * .8)**4
    save("water_lap", stereo(lap, -.1), .13, True)
    t = np.arange(int(SR * 1.2)) / SR
    gust = noise(1.2, 950) * np.sin(np.pi * t / 1.2)**1.7
    save("gust", stereo(gust), .2)
    for index in range(3):
        save("leaf_drip_%d" % (index + 1), room(stereo(drop(freq=1050 + index * 230)), False), .22)
    t = np.arange(int(SR * .7)) / SR
    flut = noise(.7, 2600, 380) * np.exp(-t * 5) * (np.sin(t * 95)**8 + .3 * np.sin(t * 153)**8)
    save("paper_flutter", stereo(flut), .105)
    for index in range(2):
        t = np.arange(int(SR * .26)) / SR
        bump = (np.sin(2 * np.pi * (145 + index * 30) * t) * .6 + noise(.26, 520) * .3) * np.exp(-t * 25) * (1 - np.exp(-t * 500))
        save("hull_bump_%d" % (index + 1), bump, .2)
    t = np.arange(int(SR * .36)) / SR
    save("petal_brush", noise(.36, 1700, 230) * np.sin(np.pi * t / .36)**2, .1)
    chain = np.zeros((int(SR * 2.8), 2))
    for i, when in enumerate([.03,.29,.58,1.04,1.19,1.62,2.04,2.44]):
        add(chain, drop(.35, 800 + i * 87), when, RNG.uniform(-.3,.3), .14)
        if i % 3 == 0:
            add(chain, note(88 + i % 3, .7, "bell"), when + .04, .1, .025)
    save("rain_chain", room(chain), .18)
    chime = np.zeros((int(SR * 4.8), 2))
    for when, midi, pan in [(0,86,-.4),(.37,90,.3),(.89,93,-.1)]:
        add(chime, note(midi, 3.8, "bell"), when, pan, .11)
    save("wind_chime", room(chime), .2)
    accent = np.zeros((int(SR * 6), 2))
    for i, midi in enumerate([50,57,62,66,69,74,78]):
        add(accent, note(midi, 5.5, "pad" if i < 3 else "bell"), i * .065, (i - 3) * .12, .12)
    save("arrival_accent", room(accent), .3)


if __name__ == "__main__":
    score()
    effects()
    (HERE / "audio_render_report.json").write_text(json.dumps(REPORT, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"assets": len(REPORT), "total_bytes": sum(v["bytes"] for v in REPORT.values()), "music_seconds": LOOP}))
