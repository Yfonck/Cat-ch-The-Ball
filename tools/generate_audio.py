#!/usr/bin/env python3
"""Generates the Cat-ch the Ball placeholder audio (mono WAV, 44.1 kHz / 16-bit).

Usage:
    python tools/generate_audio.py

Files are written to assets/audio/ and can be replaced with real audio while
keeping the same filenames.
"""

import math
import os
import random
import struct
import wave

SR = 44100
TWO_PI = 2.0 * math.pi
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "audio")

NOTE_OFFSETS = {
    "C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5,
    "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11,
}


def note_freq(name):
    """Converts 'A4', 'C#5', etc. to a frequency in Hz."""
    if len(name) == 3:
        pitch, octave = name[:2], int(name[2])
    else:
        pitch, octave = name[0], int(name[1])
    semitone = NOTE_OFFSETS[pitch] + (octave - 4) * 12
    return 440.0 * (2.0 ** ((semitone - 9) / 12.0))


def make_buffer(seconds):
    return [0.0] * int(round(seconds * SR))


def add_note(buf, start, duration, freq, amp, attack=0.005, decay=0.35,
             release=0.03, harmonics=(1.0,), vibrato=0.0):
    start_i = int(start * SR)
    n = int(duration * SR)
    end_i = min(len(buf), start_i + n)
    for i in range(max(0, start_i), end_i):
        t = (i - start_i) / SR
        env = 1.0
        if attack > 0.0:
            env *= min(1.0, t / attack)
        if decay > 0.0:
            env *= math.exp(-t / decay)
        if release > 0.0 and duration - t < release:
            env *= max(0.0, (duration - t) / release)
        phase = TWO_PI * freq * t
        if vibrato:
            phase += vibrato * math.sin(TWO_PI * 6.0 * t)
        s = 0.0
        for k, h in enumerate(harmonics, 1):
            s += h * math.sin(phase * k)
        buf[i] += amp * env * s


def add_sweep(buf, start, duration, f0, f1, amp, attack=0.005, decay=0.12,
              release=0.02, vibrato=0.0):
    start_i = int(start * SR)
    n = int(duration * SR)
    end_i = min(len(buf), start_i + n)
    phase = 0.0
    for i in range(max(0, start_i), end_i):
        t = (i - start_i) / SR
        frac = min(1.0, t / duration)
        f = f0 + (f1 - f0) * frac
        if vibrato:
            f *= 1.0 + vibrato * math.sin(TWO_PI * 7.0 * t)
        phase += TWO_PI * f / SR
        env = min(1.0, t / attack) if attack > 0.0 else 1.0
        if decay > 0.0:
            env *= math.exp(-t / decay)
        if release > 0.0 and duration - t < release:
            env *= max(0.0, (duration - t) / release)
        buf[i] += amp * env * math.sin(phase)


def add_noise(buf, start, duration, amp, decay=0.02):
    start_i = int(start * SR)
    n = int(duration * SR)
    end_i = min(len(buf), start_i + n)
    for i in range(max(0, start_i), end_i):
        t = (i - start_i) / SR
        env = math.exp(-t / decay) if decay > 0.0 else 1.0
        buf[i] += amp * env * random.uniform(-1.0, 1.0)


def normalize(buf, peak=0.89):
    maximum = max(1e-9, max(abs(v) for v in buf))
    return [v / maximum * peak for v in buf]


def write_wav(filename, buf, fade_ms=8.0):
    buf = normalize(buf)
    if fade_ms > 0.0:
        fade = max(1, int(SR * fade_ms / 1000.0))
        for i in range(fade):
            gain = i / fade
            buf[i] *= gain
            buf[-1 - i] *= gain
    data = bytearray()
    for value in buf:
        sample = int(max(-1.0, min(1.0, value)) * 32767)
        data += struct.pack("<h", sample)
    path = os.path.join(OUT_DIR, filename)
    with wave.open(path, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SR)
        wav.writeframes(bytes(data))
    print("  {0:18s} {1:6.2f} s  {2:7.1f} KB".format(
        filename, len(buf) / SR, os.path.getsize(path) / 1024.0))


def gen_click():
    buf = make_buffer(0.07)
    add_sweep(buf, 0.0, 0.035, 1500.0, 950.0, 0.55, decay=0.015)
    add_sweep(buf, 0.004, 0.05, 2400.0, 1800.0, 0.22, decay=0.02)
    return buf


def gen_cat_jump():
    buf = make_buffer(0.28)
    add_sweep(buf, 0.0, 0.22, 320.0, 760.0, 0.55, decay=0.18, vibrato=0.04)
    add_sweep(buf, 0.02, 0.18, 640.0, 1200.0, 0.14, decay=0.12)
    add_note(buf, 0.05, 0.18, 880.0, 0.07, decay=0.10, harmonics=(1.0, 0.5))
    return buf


def gen_bounce():
    buf = make_buffer(0.17)
    add_sweep(buf, 0.0, 0.14, 720.0, 240.0, 0.55, decay=0.09)
    add_note(buf, 0.0, 0.12, 440.0, 0.16, decay=0.08, harmonics=(1.0, 0.5))
    return buf


def gen_game_over():
    buf = make_buffer(1.05)
    for note, start in (("A4", 0.0), ("F4", 0.16), ("D4", 0.32),
                        ("A3", 0.48), ("D3", 0.64)):
        add_note(buf, start, 0.38, note_freq(note), 0.40,
                 decay=0.30, harmonics=(1.0, 0.35, 0.15))
    add_note(buf, 0.64, 0.36, note_freq("D3"), 0.16,
             decay=0.42, harmonics=(1.0, 0.5))
    return buf


def gen_music_menu():
    bpm = 84.0
    beat = 60.0 / bpm
    bars = 8
    buf = make_buffer(bars * 4 * beat)
    progression = [
        ("A2", ["A3", "C4", "E4", "A4"]),
        ("F2", ["F3", "A3", "C4", "F4"]),
        ("C3", ["C4", "E4", "G4", "C5"]),
        ("G2", ["G3", "B3", "D4", "G4"]),
    ]
    for chord_index, (bass, chord) in enumerate(progression):
        base = chord_index * 2 * 4 * beat
        for bar in range(2):
            bar_start = base + bar * 4 * beat
            add_note(buf, bar_start, beat * 1.8, note_freq(bass), 0.18,
                     decay=0.9, harmonics=(1.0, 0.4))
            for eighth in range(8):
                note = chord[eighth % len(chord)]
                add_note(buf, bar_start + eighth * beat / 2.0, beat * 0.45,
                         note_freq(note), 0.07, decay=0.35,
                         harmonics=(1.0, 0.3))
    melody = [
        ("E5", 0), ("C5", 2), ("D5", 0), ("E5", 2),
        ("C5", 0), ("A4", 2), ("C5", 0), ("D5", 2),
        ("E5", 0), ("G5", 2), ("E5", 0), ("D5", 2),
        ("D5", 0), ("B4", 2), ("A4", 0), ("E4", 2),
    ]
    for index, (note, beat_offset) in enumerate(melody):
        bar = index // 2
        start = bar * 4 * beat + beat_offset * beat
        add_note(buf, start, beat * 1.6, note_freq(note), 0.20,
                 decay=0.60, harmonics=(1.0, 0.35, 0.12))
    return buf


def gen_music_game():
    random.seed(7)
    bpm = 112.0
    beat = 60.0 / bpm
    bars = 8
    buf = make_buffer(bars * 4 * beat)
    progression = [
        ("C3", ["C4", "E4", "G4", "C5"]),
        ("A2", ["A3", "C4", "E4", "A4"]),
        ("F2", ["F3", "A3", "C4", "F4"]),
        ("G2", ["G3", "B3", "D4", "G4"]),
    ]
    for chord_index, (bass, chord) in enumerate(progression):
        base = chord_index * 2 * 4 * beat
        for bar in range(2):
            bar_start = base + bar * 4 * beat
            for beat_index in (0, 2):
                add_note(buf, bar_start + beat_index * beat, beat * 0.8,
                         note_freq(bass), 0.20, decay=0.35,
                         harmonics=(1.0, 0.5))
            for eighth in range(8):
                note = chord[eighth % len(chord)]
                add_note(buf, bar_start + eighth * beat / 2.0, beat * 0.35,
                         note_freq(note), 0.07, decay=0.20,
                         harmonics=(1.0, 0.4))
                if eighth % 2 == 1:
                    add_noise(buf, bar_start + eighth * beat / 2.0, 0.04,
                              0.03, decay=0.02)
    melody = [
        ("E5", 0), ("G5", 0), ("C5", 0), ("E5", 0),
        ("A4", 0), ("C5", 0), ("E5", 0), ("D5", 0),
        ("C5", 0), ("A4", 0), ("F4", 0), ("A4", 0),
        ("B4", 0), ("D5", 0), ("G4", 0), ("B4", 0),
    ]
    for index, (note, _offset) in enumerate(melody):
        bar = index // 2
        beat_in_bar = (index % 2) * 2
        start = bar * 4 * beat + beat_in_bar * beat
        add_note(buf, start, beat * 0.7, note_freq(note), 0.16,
                 decay=0.25, harmonics=(1.0, 0.5, 0.2))
    return buf


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print("Generating audio in {0}".format(OUT_DIR))
    write_wav("ui_click.wav", gen_click())
    write_wav("cat_jumps.wav", gen_cat_jump())
    write_wav("ball_bounce.wav", gen_bounce())
    write_wav("game_over.wav", gen_game_over())
    write_wav("music_menu.wav", gen_music_menu())
    write_wav("music_game.wav", gen_music_game())
    print("Done.")


if __name__ == "__main__":
    main()
