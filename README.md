# Keyboard Layout Practicer


## Keymap

The keymap is a 'tsv' or 'csv' file with the following four columns:

character | reading | key | audio
--------- | ------- | --- | -----
ㄅ        | b       | 1   | 1_B.mp3
ㄆ        | p       | q   | 2_P.mp3
...       | ...     | ... | ...

The columns have to have exactly the specified header names, though their order does not matter.

### "character":

The string to be displayed as the question, i.e. the character you want to learn the correct reading/key for.

### "reading" (optional):

The reading to be typed in in Reading Mode or to be revealed in Key Mode. If left empty, the character will not appear in Reading Mode.

### "key" (optional):

The key to be pressed in Key Mode. If left empty, the character will not appear in Key Mode.

### "audio" (optional):

The name of the audio file to be played when the corresponding character's solution is revealed.
By default these files have to be in the subfolder 'audio', though this can be changed via the `AUDIO_FILES_FOLDER` constant (See __Configuaration__ for details).


## Configuration

The configuration is done via constant variables at the top of the code. Below an explanation what each constant does.

### `KEYMAP_FILE`:

Default: `"keymap.tsv"`

The name of the file from which the keymap is loaded. See __Keymap__ for details on the format.

### `AUDIO_FILES_FOLDER`:

Default: `"audio/"`

The folder containing the audio files referenced in the "audio" column in the keymap. Can be any kind of path. Don't forget the `/` at the end!

### `DARK_MODE`:

Alias for `true` :P

### `SCORE_CORRECT`:

Added when pressing/entering. the right key/reading.

### `SCORE_INCORRECT`:

Added when pressing/entering the wrong key/reading or when giving up.

### `SCORE_MINIMUM`:

The mininum below which scores are not permitted to drop.

### `SCORE_DECAY`:

This value is added each round to all characters that were NOT tested.

### `PICK_SAMPLES`:

When picking the next character, this number determines how many are randomly sampled, of which the one with the lowest score will be chosen.
Therefore, the higher this number, the less random the selection is.
