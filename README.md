## instrument schematic
![PXL_20240111_010816098~2](https://github.com/nshaheed/degredation/assets/6963603/ade05717-2dc6-4545-965d-2042928bd79f)


This is the current structure of the instrument, subject to change!

It shows the pathway of how the audio (the loop, microphone input, and one of the field recordings) will be mixed together and where the other gestures (addition, mulitplication, freezing, and muting) fit into the latent circuit.


## API

Here is the OSC api, there will be two RAVE models - a left and a right one. To update the right one, just replace `/left/` with `/right/` in the osc address.
```
# The model has 16 latent dimensions that can be manipulated
# The idx gives the dimension number (0-15) and the f gives the value to be added it it
/left/add, idx f

# multiply all latent dimensions by a scalar
/left/mult, f

# mute == true sets all latent values to 0 (this won't stop generating sound, as the 0s are fed into the decoder)
/left/mute, bool

# freezes the latent values in time, number of dimensions frozen given by input:
# 0 - nothing is frozen
# 1 - first dim is frozen
# 2 - first and second dim are frozen
# etc, etc,
# up to 15
/left/freeze, int

# amount of mic input to mix in (send values 0-1)
/left/mic/mix, float

# amount of field recording input to mix in (send values 0-1)
/left/rec/mix, float

# amount of loop audio to mix in (send values 0-1)
/left/loop/mix, float

```
