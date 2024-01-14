// TODO: make this a constructor

"Midi Fighter Twister" => string device;

MidiIn min;
MidiMsg msg;

// try to open MIDI port (see chuck --probe for available devices)
if( !min.open( device ) ) me.exit();

// print out device that was opened
<<< "MIDI device:", min.num(), " -> ", min.name() >>>;

spork~ handleMidi();

float knobs[64];

eon => now;

fun handleMidi() {
    // destination host name
    "localhost" => string hostname;
    // destination port number
    6449 => int port;

    // sender object
    OscOut xmit;

    // aim the transmitter at destination
    xmit.dest( hostname, port );

    /*
    3::second => now;
    xmit.start("/start");
    xmit.send();
    */

    0.01 => float increment;
    while(true) {
        // wait on the event 'min'
        min => now;

        // get the message(s)
        while( min.recv(msg) )
        {
            // print out midi message
            <<< msg.data1, msg.data2, msg.data3 >>>;

            if (msg.data1 == 176) {
                msg.data2 => int idx;

                // add
                if (idx < 16) {
                    // store val
                    msg.data3 - 64 => float dir;
                    dir * increment +=> knobs[idx] => float val;

                    xmit.start("/left/add");

                    idx => xmit.add;
                    val => xmit.add;
                    xmit.send();
                }

                // multiply
                if (idx == 16) {
                    <<< "mulitply!" >>>;
                    Math.map(msg.data3, 0, 127, 0, 3) => float val => knobs[idx];
                    xmit.start("/left/mult");

                    val => xmit.add;
                    xmit.send();
                }
                // mic mix
                if (idx == 17) {
                    <<< "mic mix!" >>>;
                    Math.map(msg.data3, 0, 127, 0, 1) => float val => knobs[idx];
                    xmit.start("/left/mic/mix");

                    val => xmit.add;
                    xmit.send();
                }
                // rec mix
                if (idx == 18) {
                    <<< "rec mix!" >>>;
                    Math.map(msg.data3, 0, 127, 0, 1) => float val => knobs[idx];
                    xmit.start("/left/rec/mix");

                    val => xmit.add;
                    xmit.send();
                }
                <<< msg.data2, knobs[msg.data2] >>>;
            }

            // side button pushes
            if (msg.data1 == 179) {

                if (msg.data2 == 8) {
                    xmit.start("/left/mute");

                    msg.data3 => xmit.add;
                    xmit.send();

                }
            }


        }
    }
}
