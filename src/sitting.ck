class Sitting extends Chugraph {
    load( "../audio/loop.wav" ) @=> LiSa @ degrade;
    SndBuf loop("../audio/loop.wav");
    "../models/dataset1_c8864be852_streaming.ts" => string model;

    16 => int chans;

    // Put loop in center of mix
    loop => Pan2 loop_pan => blackhole; // outlet;

    // loop audio encoder and decoder
    Mix2 m => Rave loop_encode => Rave loop_decode => blackhole;
    loop_encode.init(model, "encode");
    loop_decode.init(model, "decode");

    degrade => m.left;
    loop => m.right;
    -1 => m.pan;

    loop_decode => outlet;

    spork~ updater();


    // Feedback loop
    // lisa => Mix2 loop_mix => Rave destruct_encode => 

    // loop => Rave loopE;

    // update the lisa samples
    fun updater() {
        while (1::samp => now) {
            (now - 1::samp) % degrade.duration() => dur pos;
            degrade.valueAt(loop_decode.last(), pos);
        }
    }
    
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
}

spork~ Rec.auto();

Sitting s => dac;

10::minute => now;