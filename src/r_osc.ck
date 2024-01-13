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
                // expected datatypes: int float
                // (note: as indicated by "if")
                float f;

                // fetch the second data element as float
                msg.getFloat(0) => f; // => s.gain;

                // print
                cherr <= f <= IO.newline();
            }
        }
    }
}

spork~ processAdd();
spork~ processMult();
eon => now;