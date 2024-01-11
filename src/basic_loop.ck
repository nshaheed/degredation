// i am sitting on a cello...

SndBuf buf => Rave r => dac;

r.help();

"../models/dataset1_c8864be852_streaming.ts" => r.model;
"../audio/dataset_1.wav" => buf.read;
true => buf.loop;

eon => now;