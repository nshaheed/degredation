
// spork~ Rec.auto();

// Set up up actual loop
"../audio/loop.wav" => string loop_file;
Sitting.load( "../audio/loop.wav" ) @=> LiSa @ loop;
loop => Pan2 p_loop => 
    // dac;
    blackhole;

// Set up left/right degredation loops
Sitting left => Pan2 p_left => dac;
-1 => p_left.pan;

/*
Sitting right => Pan2 p_right => dac;
1 => p_right.pan;
*/

// OSC handlers
spork~ processAdd();
spork~ processMult();
spork~ processMute();
spork~ processMicMix();


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
    653::ms + 2048::samp => dur delay;

    load( "../audio/loop.wav" ) @=> LiSa @ degrade;
    
    "../models/dataset1_c8864be852_streaming.ts" => string model;

    16 => int chans;

    // loop audio encoder and decoder
    degrade => Rave loop_encode => Rave loop_decode => blackhole;
    loop_encode.init(model, "encode");
    loop_decode.init(model, "decode");

    // output decoder - this makes the actual sound
    // loop_encode => 
    
    Gain mic_mix[chans] => Gain mute[chans] => Gain mult[chans] => Rave output_decoder => outlet;

    

    // Set up microphone input/encoding
    adc => Rave mic_encode => Gain mic_levels[chans]  => mic_mix;
               loop_encode => Gain loop_levels[chans] => mic_mix;
    mic_encode.init(model, "encode");

    for (int i: Std.range(chans)) {
        // Pass-through the loop at initalization
        1 => loop_levels[i].gain;
        0 => mic_levels[i].gain;
    }
    // adc => dac;

    // addition gesture
    Step add(0)[chans] => mult;
    
    output_decoder.init(model, "decode");

    spork~ updater();

    // loop_decode => outlet;

    // update the lisa samples
    fun updater() {
        while (1::samp => now) {
            (now - 1::samp) % degrade.duration() => dur pos;
            degrade.valueAt(loop_decode.last(), pos);
        }
    }

    fun addChan(int chan, float val) {
        val => add[chan].next;
    }

    fun multChan(float f) {
        for (Gain g: mult) {
            f => g.gain;
        }
    } 

    fun muteChan() {
        for (Gain g: mute) {
            0 => g.gain;
        }
    }

    fun unmuteChan() {
        for (Gain g: mute) {
            1 => g.gain;
        }
    }

    fun mic(float f) {
        for (int i: Std.range(chans)) {
            // Pass-through the loop at initalization
            1 - f => loop_levels[i].gain;
            f => mic_levels[i].gain;
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
        // lisa.loop( true );
        // lisa.bi( true );

        return lisa;
    }
}


fun processAdd() {
    // create our OSC receiver
    OscIn oin;
    // create our OSC message
    OscMsg msg;
    // use port 6449 (or whatever)
    6449 => oin.port;
    // create an address in the receiver, expect an int and a float
    oin.addAddress( "/left/add" );


    // infinite event loop
    while( true )
    {
        // wait for event to arrive
        oin => now;

        // grab the next message from the queue. 
        while( oin.recv(msg) )
        {
            // print stuff
            cherr <= "received OSC message: \"" <= msg.address <= "\" "
                <= "typetag: \"" <= msg.typetag <= "\" "
                <= "arguments: " <= msg.numArgs() <= IO.newline();

            // check typetag for specific types
            if( msg.typetag == "if" )
            {
                // expected datatypes: int float
                // (note: as indicated by "if")
                int i;
                float f;

                // fetch the first data element as int
                msg.getInt(0) => i;
                // fetch the second data element as float
                msg.getFloat(1) => f; // => s.gain;

                // print
                cherr <= i <= ", " <= f <= IO.newline();

                left.addChan(i, f);
            }
        }
    }
}

fun processMult() {
    // create our OSC receiver
    OscIn oin;
    // create our OSC message
    OscMsg msg;
    // use port 6449 (or whatever)
    6449 => oin.port;
    // create an address in the receiver, expect an int and a float
    oin.addAddress( "/left/mult" );


    // infinite event loop
    while( true )
    {
        // wait for event to arrive
        oin => now;

        // grab the next message from the queue. 
        while( oin.recv(msg) )
        {
            // print stuff
            cherr <= "received OSC message: \"" <= msg.address <= "\" "
                <= "typetag: \"" <= msg.typetag <= "\" "
                <= "arguments: " <= msg.numArgs() <= IO.newline();

            // check typetag for specific types
            if( msg.typetag == "f" )
            {
                <<< "multiply!" >>>;
                // expected datatypes: int float
                // (note: as indicated by "if")
                float f;

                // fetch the second data element as float
                msg.getFloat(0) => f; // => s.gain;

                // print
                cherr <= f <= IO.newline();

                left.multChan(f);
            }
        }
    }
}

fun processMute() {
    // create our OSC receiver
    OscIn oin;
    // create our OSC message
    OscMsg msg;
    // use port 6449 (or whatever)
    6449 => oin.port;
    // create an address in the receiver, expect an int and a float
    oin.addAddress( "/left/mute" );


    // infinite event loop
    while( true )
    {
        // wait for event to arrive
        oin => now;

        // grab the next message from the queue. 
        while( oin.recv(msg) )
        {
            // print stuff
            cherr <= "received OSC message: \"" <= msg.address <= "\" "
                <= "typetag: \"" <= msg.typetag <= "\" "
                <= "arguments: " <= msg.numArgs() <= IO.newline();

            // check typetag for specific types
            if( msg.typetag == "i" )
            {
                <<< "mute!" >>>;
                // expected datatypes: int float
                // (note: as indicated by "if")
                int i;

                // fetch the second data element as float
                msg.getInt(0) => i; // => s.gain;

                // print
                cherr <= i <= IO.newline();

                if (i) {
                    left.muteChan();
                } else {
                    left.unmuteChan();
                }
            }
        }
    }
}

fun processMicMix() {
    // create our OSC receiver
    OscIn oin;
    // create our OSC message
    OscMsg msg;
    // use port 6449 (or whatever)
    6449 => oin.port;
    // create an address in the receiver, expect an int and a float
    oin.addAddress( "/left/mic/mix" );


    // infinite event loop
    while( true )
    {
        // wait for event to arrive
        oin => now;

        // grab the next message from the queue. 
        while( oin.recv(msg) )
        {
            // print stuff
            cherr <= "received OSC message: \"" <= msg.address <= "\" "
                <= "typetag: \"" <= msg.typetag <= "\" "
                <= "arguments: " <= msg.numArgs() <= IO.newline();

            // check typetag for specific types
            if( msg.typetag == "f" )
            {
                <<< "micing!" >>>;
                // expected datatypes: int float
                // (note: as indicated by "if")
                float f;

                // fetch the second data element as float
                msg.getFloat(0) => f; // => s.gain;

                // print
                cherr <= f <= IO.newline();

                left.mic(f);
            }
        }
    }
}