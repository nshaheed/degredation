// i am sitting on a cello...

Rave r => dac;

// r.help();

r.init("../models/dataset1_c8864be852_streaming.ts", "decode");

SinOsc s(0.1) => r.chan(0);
// "../audio/dataset_1.wav" => buf.read;
// true => buf.loop;

// latent space is 16-dim
<<< "out chan", r.inChannels() >>>;
eon => now;