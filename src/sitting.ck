
// spork~ Rec.auto();

// Set up up actual loop
"../audio/loop.wav" => string loop_file;
Sitting.load( "../audio/loop.wav" ) @=> LiSa @ loop;
loop => Pan2 p_loop => blackhole; // dac;

// Set up left/right degredation loops
Sitting left(-1) => Pan2 p_left => dac;
-1 => p_left.pan;

/*
Sitting right(1) => Pan2 p_right => dac;
1 => p_right.pan;
*/


// vibe
20::minute => now;

/* 
 chugraphs are only mono (which is fine)

 the next things I want to do are to 
 - test out putting loop in middle, and then left/right Sitting instances
 - slightly change feedback values
 - start adding more parts to it
*/
class Sitting extends Chugraph {
    load( "../audio/loop.wav" ) @=> LiSa @ degrade;
    load( "../audio/loop.wav" ) @=> LiSa @ loop;
    // SndBuf loop("../audio/loop.wav");
    // 1 => loop.loop;
    "../models/dataset1_c8864be852_streaming.ts" => string model;

    16 => int chans;

    // Put loop in center of mix
    // loop => Pan2 loop_pan => outlet;

    // loop audio encoder and decoder
    Mix2 m => Rave loop_encode => Rave loop_decode => blackhole;
    loop_encode.init(model, "encode");
    loop_decode.init(model, "decode");

    degrade => m.left;
    loop => Delay d => m.right;

/*
    spork~ Rec.mono(degrade, me.dir() + "m-left");
    spork~ Rec.mono(d, me.dir() + "m-right");
    */
    
    // official  RAVE(tm) delay time
    653::ms + 2048::samp => d.max => d.delay;
    // m => outlet;
    // loop => outlet;
    // loop_decode => outlet;
    // d => outlet;


    //-1 => m.pan;

    loop_decode => outlet;

    spork~ updater();

    fun @construct(float loop_mix) {
        // set how much the original is mixed back in (-1,1)
        loop_mix => m.pan;
    }

    fun @construct() {
        -1 => m.pan;
    }

    // update the lisa samples
    fun updater() {
        while (1::samp => now) {
            (now - 1::samp) % degrade.duration() => dur pos;
            degrade.valueAt(loop_decode.last(), pos);
        }
    }
    
    // create a new LiSa pre-loaded with the specified file
    fun static LiSa load( string filename )
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
