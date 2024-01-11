// i am sitting on a cello...

load( "../audio/loop.wav" ) @=> LiSa @ lisa;

lisa => Rave r => Pan2 p1 => dac;
lisa => Pan2 p2 => dac;

-1 => p1.pan;
1 => p2.pan;
// 0 => p2.gain;
// Dyno d => dac;

// set dyno to default compress mode
// d.compress();

// "../models/rave_chafe_data_rt.ts" => r.model;
// "../models/stetson.ts" => r.model;
"../models/dataset1_c8864be852_streaming.ts" => r.model;

// eon => now;


// 1.0 => float normalizeVal;
// spork~ normalizeWatch();

while (1::samp => now) {
    (now - 1::samp) % lisa.duration() => dur pos;
    lisa.valueAt(r.last(), pos);
    // try to record while also playing back. will it work? I dunno
    // <<< "here" >>>;
}

eon => now;

/*
fun void normalizeWatch() {
    while (true) {
        normalizeAmount(d, lisa.duration());
        <<< "Gain adjust:", normalizeVal >>>;
    }
}
*/

/*
// return gain change needed to normalize audio for a single loop
fun void normalizeAmount(UGen ugen, dur length) {
    // calculate rms
    ugen => FFT fft =^ RMS rms => blackhole;

    // set parameters
    1024 => fft.size;
    // set hann window
    Windowing.hann(1024) => fft.window;

    float maxRMS;

    length => dur timeleft;

    while (timeleft > 0::samp) {
        Math.max(ugen.last(), maxRMS) => maxRMS;

        timeleft - 1::samp => timeleft;
        1::samp => now;
    }

/*
    while (timeleft >= fft.size()::samp) {
        fft.size()::samp => now;

        rms.upchuck() @=> UAnaBlob blob;

        // check if it's the max rms
        Math.max(blob.fval(0), maxRMS) => maxRMS;

        <<< "MaxRMS", maxRMS >>>;

        timeleft - fft.size()::samp => timeleft;
    }
*/

/*
    // return amount of gain change needed to normalize
    (1.0 / maxRMS) => normalizeVal;
    normalizeVal => lisa.gain;
}
*/


// create a new LiSa pre-loaded with the specified file
fun LiSa load( string filename )
{
    // sound buffer
    SndBuf buffy;
    // load it
    filename => buffy.read;

    // instantiate new LiSa (will be returned)
    LiSa lisa;
    // set duration
    buffy.samples()::samp => lisa.duration;

    // transfer values from SndBuf to LiSa
    for( 0 => int i; i < buffy.samples(); i++ )
    // for( 0 => int i; i < 441000; i++)
    {
        // args are sample value and sample index
        // (dur must be integral in samples)
        lisa.valueAt( buffy.valueAt(i), i::samp );        
    }

    // set default LiSa parameters; actual usage parameters intended
    // to be set to taste by the user after this function returns
    lisa.play( true );
    lisa.loop( true );
    // lisa.bi( true );

    return lisa;
}
