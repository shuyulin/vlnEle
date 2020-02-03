
/*
A study for violin and electronics- script for electronics
March 2018 created
Feb 2020 revised

Electronics part will be played through stereo speakers that will be placed beside the violinist on the stage. The electronics performer will trigger the sounds (see line 616 BEGIN part) real-time at the control desk.
*/


////////////////////////////////// PREP //////////////////////////////////

(
s.waitForBoot {

	~midiBlock = [ [ [ 64, 60, 61, 66, 71, 60, 68 ], [ 68, 60, 71, 66, 61, 60, 64 ], [ 64, 68, 67, 62, 69, 68, 60 ], [ 60, 68, 69, 62, 67, 68, 64 ] ], [ [ 61, 69, 70, 63, 68, 69, 65 ], [ 65, 69, 68, 63, 70, 69, 61 ], [ 61, 65, 64, 71, 66, 65, 69 ], [ 69, 65, 66, 71, 64, 65, 61 ] ], [ [ 66, 62, 63, 68, 61, 62, 70 ], [ 70, 62, 61, 68, 63, 62, 66 ], [ 66, 70, 69, 64, 71, 70, 62 ], [ 62, 70, 71, 64, 69, 70, 66 ] ], [ [ 71, 67, 68, 61, 66, 67, 63 ], [ 63, 67, 66, 61, 68, 67, 71 ], [ 71, 63, 62, 69, 64, 63, 67 ], [ 67, 63, 64, 69, 62, 63, 71 ] ], [ [ 68, 64, 65, 70, 63, 64, 60 ], [ 60, 64, 63, 70, 65, 64, 68 ], [ 68, 60, 71, 66, 61, 60, 64 ], [ 64, 60, 61, 66, 71, 60, 68 ] ] ];

	// remove repeated notes (two same notes in the row)
	~oldNote = 40;
	~filterNote = {
		~newNote = (~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)]);
		if(~newNote == ~oldNote, {
			~newNote = (~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)]);
		});
		~oldNote = ~newNote;
		~newNote;
	};

	SynthDef("playRandNotesSine", {
		arg freq, env, amp = 0.8, out = 0, pan = 1; // pan = -1 = start from left
		var sig, outArray, bus;
		sig = SinOsc.ar(freq, 0, amp);
		env = EnvGen.kr(Env.new([0, 1, 0.3, 0], [0.0001, 0.1, 1.8],[-5, 0, -3]), doneAction: 2);
		outArray = sig * env * amp; // only 1 signal in the array
		outArray = Pan2.ar(outArray,pan); // add this line for panning
		Out.ar(out, outArray); // output to left channel
	}).add; // add to server to be played later

	SynthDef("playRandNotesSaw", {
		arg freq, env, amp = 0.8, out=0, pan= 1;
		var sig, outArray, bus;
		sig = RLPF.ar(Resonz.ar(BPF.ar(Saw.ar(freq, amp), freq, 1), freq, 1), freq, 1);
		env = EnvGen.kr(Env.new([0, 1, 0.3, 0], [0.0001, 0.1, 1.8],[-5, 0, -3]), doneAction: 2);
		outArray = sig * env * amp;
		outArray = Pan2.ar(outArray, pan);
		Out.ar(out, outArray);
	}).add;

	SynthDef("playRandNotesSawPan", {
		arg freq, env, amp = 0.8, out=0, pan= -1;
		var sig, outArray, bus;
		sig = RLPF.ar(Resonz.ar(BPF.ar(Saw.ar(freq, amp), freq, 1), freq, 1), freq, 1);
		env = EnvGen.kr(Env.new([0, 1, 0.3, 0], [0.0001, 0.1, 1.8],[-5, 0, -3]), doneAction: 2);
		outArray = sig * env * amp;
		outArray = Pan2.ar(outArray, pan);
		Out.ar(out, outArray);
	}).add;

	SynthDef("shep", {
		arg amp = 0.08, freq = 440;
		var sig;
		sig = SinOsc.ar([freq, freq]);
		sig = sig * amp;
		Out.ar(0, sig);
	}).add;


	~playShep1 = {
		arg	speed = 0.015, volume = 0.5, direction = 0, centerFreqShift = 0;
		var	pat0, pat1, pat2, pat3, pat4, pat5, pat6, pat7, pat8, midiArray, ampArray;
		midiArray = (6,6.01..113.99);
		ampArray = Array.newClear(10800);

		(-5400..5399).do {
			arg val, index;
			ampArray[index] = 1.000001.pow((val.pow(2).neg));
		};

		if (
			direction > 0,
			{midiArray},
			{midiArray = midiArray.reverse});

		midiArray = midiArray + centerFreqShift;

		pat0 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray, inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1), Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray,inf), ]);

		pat1 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-1200), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1), Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-1200), inf), ]);

		pat2 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-2400), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1), Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-2400), inf), ]);

		pat3 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-3600), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1), Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote:Pseq(midiArray.rotate(-3600), inf), ]);

		pat4 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-4800), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-4800), inf), ]);

		pat5 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-6000), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-6000), inf), ]);

		pat6 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-7200), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-7200), inf), ]);

		pat7 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-8400), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-8400), inf), ]);

		pat8 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-9600), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-9600), inf), ]);

		~p1 = Pspawner({
			arg sp;
			sp.par(pat0);
			sp.par(pat1);
			sp.par(pat2);
			sp.par(pat3);
			sp.par(pat4);
			sp.par(pat5);
			sp.par(pat6);
			sp.par(pat7);
			sp.par(pat8);
		});
		Ndef(\shepStream1, ~p1).play;
	};

	~playShep2 = {
		arg	speed = 0.015, volume = 0.5, direction = 0, centerFreqShift = 0;
		var	pat0, pat1, pat2, pat3, pat4, pat5, pat6, pat7, pat8, midiArray, ampArray;
		midiArray=(6,6.01..113.99);
		ampArray = Array.newClear(10800);

		(-5400..5399).do {
			arg val, index;
			ampArray[index]= 1.000001.pow((val.pow(2).neg));
		};

		if (
			direction > 0,
			{midiArray},
			{midiArray = midiArray.reverse});

		midiArray = midiArray + centerFreqShift;

		pat0 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray, inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1), Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray,inf), ]);

		pat1 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-1200), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1), Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-1200), inf), ]);

		pat2 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-2400), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1), Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-2400), inf), ]);

		pat3 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-3600), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1), Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote:Pseq(midiArray.rotate(-3600), inf), ]);

		pat4 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-4800), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-4800), inf), ]);

		pat5 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-6000), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-6000), inf), ]);

		pat6 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-7200), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-7200), inf), ]);

		pat7 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-8400), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-8400), inf), ]);

		pat8 = Pmono(* [\shep,
			dur: speed,
			amp:
			Pseq(ampArray.rotate(-9600), inf) *
			Pseq([
				Pseg(Pseq([0, 1], 1),Pseq([1, 0], 1), \sine),
				Pseq([1], inf)
			], 1) * volume,
			midinote: Pseq(midiArray.rotate(-9600), inf), ]);

		~p2 = Pspawner({
			arg sp;
			sp.par(pat0);
			sp.par(pat1);
			sp.par(pat2);
			sp.par(pat3);
			sp.par(pat4);
			sp.par(pat5);
			sp.par(pat6);
			sp.par(pat7);
			sp.par(pat8);
		});
		Ndef(\shepStream2, ~p2).play;
	};

	//// 1
	Pdef(\1).play;
	~panArr = Array.series(18, -1, 0.111);
	~patIn1 = Pbind(\instrument, Prand(["playRandNotesSawPan"], 18), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.06, \amp, 0.7, \ctranspose, 12, \pan, Pseq(~panArr, 1));

	//// 2
	Pdef(\2).play;
	~patIn2_1 = Pbind(\instrument, Prand(["playRandNotesSine"], 8), \midinote, Pfunc({
		(~filterNote.() ).postln; // change the number of notes output in Prand
	}), \dur, 0.048, \amp, 0.05, \ctranspose, 12, \pan, 1); // this output to left channel
	~patIn2_2 = Pbind(\instrument, Prand(["playRandNotesSaw"], 8), \midinote, Pfunc({
		(~filterNote.()).postln;
	}), \dur, 0.033, \amp, 0.25, \ctranspose, 1, \pan, -1); // this output through right channel

	//// 3
	Pdef(\3).play;
	~patIn3_1 = Pbind(\instrument, Prand(["playRandNotesSine"], 8), \midinote, Pfunc({
		(~filterNote.() ).postln; // change the number of notes output in Prand
	}), \dur, 0.048, \amp, 0.4, \ctranspose, -12, \pan, -1); // this output to left channel
	~patIn3_2 = Pbind(\instrument, Prand(["playRandNotesSaw"], 10), \midinote, Pfunc({
		(~filterNote.()).postln;
	}), \dur, 0.033, \amp, 0.6, \ctranspose, 1, \pan, -1); // this output through right channel

	//// 4
	Pdef(\4).play;
	~panArr = Array.series(130, 1, -0.0153);
	~ampArr = Array.series(130, 0.7, -0.005384);
	~patIn4 = Pbind(\instrument, Prand(["playRandNotesSawPan"], 130), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.06, \amp, Pseq(~ampArr, 1), \ctranspose, 12, \pan, Pseq(~panArr, 1));

	//// 5
	// see BEGIN part

	//// 6
	~noteIn6 = ~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)].midicps;
	~a = {EnvGen.ar(Env.asr(10, 0.6, 5, 1, -4), doneAction: 2) * Pan2.ar( RLPF.ar(Resonz.ar(SinOsc.ar(~noteIn6, 0.8), ~noteIn6, 1), ~noteIn6, 1) + RLPF.ar(Resonz.ar(BPF.ar(Saw.ar(~noteIn6, 0.25), ~noteIn6, 1), ~noteIn6, 1), ~noteIn6, 1), 0)};
	~b = {EnvGen.ar(Env.asr(20, 0.6, 5, 1, -4), doneAction: 2) * Pan2.ar( RLPF.ar(Resonz.ar(SinOsc.ar(~noteIn6 + 5, 0.8), ~noteIn6, 1), ~noteIn6, 1) + RLPF.ar(Resonz.ar(BPF.ar(Saw.ar(~noteIn6 -0.5, 0.25), ~noteIn6, 1), ~noteIn6, 1), ~noteIn6, 1), 0.1)};
	~c = {EnvGen.ar(Env.asr(10, 0.5, 4, 0.5, -4), doneAction: 2) * Pan2.ar(Saw.ar(~noteIn6, 0.1), -0.15)};

	//// 7
	// see BEGIN part

	//// 8
	// see BEGIN part

	//// 9
	~noteIn9 = ~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)].midicps;
	~a9 = {EnvGen.ar(Env.asr(10, 0.5, 4, 0.5, -4), doneAction: 2) * Pan2.ar(Saw.ar(~noteIn9, 0.3), -0.15)};

	//// 10
	~panArr = Array.series(5000, 1, -0.0016);
	~ampArr = Array.series(1000, 0, 0.0001);
	~patIn10 = Pbind(\instrument, Prand(["playRandNotesSine"], 5000), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.015, \amp, Pseq(~ampArr, 1), \ctranspose, 12, \pan, Pseq(~panArr, 1));
	Pdef(\10, ~patIn10);
	~panArr102 = Array.series(5000, -0.65, 0.0008);
	~ampArr102 = Array.series(1000, 0.08, -0.00008);
	~patIn102 = Pbind(\instrument, Prand(["playRandNotesSine"], 5000), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.015, \amp, Pseq(~ampArr, 1), \ctranspose, 12, \pan, Pseq(~panArr, 1));
	Pdef(\102, ~patIn102);

	//// 11
	~panArr = Array.series(130, 0.65, -0.0153);
	~ampArr = Array.series(130, 0, 0.002);
	~patIn11 = Pbind(\instrument, Prand(["playRandNotesSawPan"], 130), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.001, \amp, Pseq(~ampArr, 1), \ctranspose, 12, \pan, Pseq(~panArr, 1));
	Pdef(\11, ~patIn11);

	//// 12
	~ampArr = Array.series(130, 0.175, -0.0002);
	~patIn12 = Pbind(\instrument, Prand(["playRandNotesSine"], 130), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.0005, \amp, Pseq(~ampArr, 1), \ctranspose, 12, \pan, 0);
	Pdef(\12, ~patIn12);

	//// 13
	~patIn13_1 = Pbind(\instrument, Prand(["playRandNotesSine"], 3), \midinote, Pfunc({
		(~filterNote.() ).postln; // change the number of notes output in Prand
	}), \dur, 0.048, \amp, 0.4, \ctranspose, -12, \pan, 1); // this output to left channel
	~patIn13_2 = Pbind(\instrument, Prand(["playRandNotesSaw"], 4), \midinote, Pfunc({
		(~filterNote.()).postln;
	}), \dur, 0.033, \amp, 0.6, \ctranspose, 1, \pan, 0); // this output through right channel
	Pdef(\13, Ppar([~patIn13_1, ~patIn13_2], 1) ); // output each pattern to each L and R speaker

	//// 14
	~patIn14_1 = Pbind(\instrument, Prand(["playRandNotesSine"], 8), \midinote, Pfunc({
		(~filterNote.() ).postln; // change the number of notes output in Prand
	}), \dur, 0.048, \amp, 0.4, \ctranspose, -12, \pan, -1); // this output to left channel
	~patIn14_2 = Pbind(\instrument, Prand(["playRandNotesSaw"], 10), \midinote, Pfunc({
		(~filterNote.()).postln;
	}), \dur, 0.033, \amp, 0.6, \ctranspose, 1, \pan, -1); // this output through right channel
	Pdef(\14, Ppar([~patIn14_1, ~patIn14_2], 1) ); // output each pattern to each L and R speaker

	//// 15
	~patIn15_1 = Pbind(\instrument, Prand(["playRandNotesSine"], 17), \midinote, Pfunc({
		(~filterNote.() ).postln; // change the number of notes output in Prand
	}), \dur, 0.048, \amp, 0.4, \ctranspose, -12, \pan, 0.7); // this output to left channel

	~patIn15_2 = Pbind(\instrument, Prand(["playRandNotesSaw"], 20), \midinote, Pfunc({
		(~filterNote.()).postln;
	}), \dur, 0.033, \amp, 0.6, \ctranspose, 12, \pan, 0.65); // this output through right channel

	Pdef(\15, Ppar([~patIn15_1, ~patIn15_2], 1) ); // output each pattern to each L and R speaker

	//// 16
	~panArr = Array.series(200, -1, 0.0153);
	~ampArr = Array.series(200, 0.7, -0.005384);
	~transposeArr = Array.series(200, -12, 0.1846);
	~patIn16 = Pbind(\instrument, Prand(["playRandNotesSawPan"], 200), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.023, \amp, Pseq(~ampArr, 1), \ctranspose, Pseq(~transposeArr, 1), \pan, Pseq(~panArr, 1));
	Pdef(\16, ~patIn16);

	//// 17
	~ampArr17 = Array.series(200, 0.4, -0.005384);
	~patIn17 = Pbind(\instrument, Prand(["playRandNotesSawPan"], 500), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.023, \amp, Pseq(~ampArr17, 1), \ctranspose, 24, \pan, -1);
	Pdef(\17, ~patIn17);
	~ampArr172 = Array.series(500, 0.4, -0.0008);
	~patIn172 = Pbind(\instrument, Prand(["playRandNotesSawPan"], 500), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.023, \amp, Pseq(~ampArr172, 1), \ctranspose, 24, \pan, 0);
	Pdef(\172, ~patIn172);
	~ampArr173 = Array.series(500, 0.4, -0.0008);
	~transposeArr173 = Array.series(500, 12, -0.024);
	~patIn173 = Pbind(\instrument, Prand(["playRandNotesSawPan"], 500), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.023, \amp, Pseq(~ampArr173, 1), \ctranspose, Pseq(~transposeArr173, 1), \pan, 1);
	Pdef(\173, ~patIn173);
	~ampArr174 = Array.series(800, 0.1, 0.00045);
	~transposeArr174 = Array.series(800, -12, 0.03);
	~panArr174 = Array.series(800, 1, -0.00125);
	~patIn174 = Pbind(\instrument, Prand(["playRandNotesSawPan"], 800), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.023, \amp, Pseq(~ampArr174, 1), \ctranspose, Pseq(~transposeArr174, 1), \pan, Pseq(~panArr174, 1));
	Pdef(\174, ~patIn174);
	~ampArr175 = Array.series(800, 0.2, -0.00025);
	~patIn175 = Pbind(\instrument, Prand(["playRandNotesSawPan"], 800), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.023, \amp, Pseq(~ampArr175, 1), \ctranspose, 12, \pan, 0);
	Pdef(\175, ~patIn175);

	//// 18
	~noteIn18 = ~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)].midicps;
	~aIn18 = {EnvGen.ar(Env.asr(0.001, 0.6, 5, 1, -4), doneAction: 2) * Pan2.ar( RLPF.ar(Resonz.ar(SinOsc.ar(~noteIn18, 0.8), ~noteIn18, 1), ~noteIn18, 1) + RLPF.ar(Resonz.ar(BPF.ar(Saw.ar(~noteIn18, 0.25), ~noteIn18, 1), ~noteIn18, 1), ~noteIn18, 1), 0)};
	~bIn18 = {EnvGen.ar(Env.asr(5, 0.8, 5, 1, -4), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn18 + 5, 0, 0.8), 0.2)};
	~cIn18 = {EnvGen.ar(Env.asr(5, 0.8, 5, 1, -4), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn18 + 10, 0, 0.8), 0)};
	~bIn18 = {EnvGen.ar(Env.asr(5, 0.8, 5, 1, -4), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn18 + 5, 0, 0.8), -0.35)};
	~dIn18 = {EnvGen.ar(Env.asr(10, 0.5, 5, 1, -4), doneAction: 2) * Pan2.ar(Saw.ar(~noteIn18 + 10, 0.5), -1)};
	~eIn18 = {EnvGen.ar(Env.asr(5, 0.6, 5, 1, -4), doneAction: 2) * Pan2.ar(RLPF.ar(Resonz.ar(SinOsc.ar(~noteIn18, 0.8), ~noteIn18, 1), ~noteIn18, 1) + RLPF.ar(Resonz.ar(BPF.ar(Saw.ar(~noteIn18, 0.25), ~noteIn18, 1), ~noteIn18, 1), ~noteIn18, 1), -0.25)};
	~fIn18 = {EnvGen.ar(Env.asr(10, 0.8, 5, 1, -4), doneAction: 2) * Pan2.ar(RLPF.ar(Resonz.ar(Saw.ar(~noteIn18 + 10, 0.8), ~noteIn18, 1), ~noteIn18, 1), 1)};
	~gIn18 =  {EnvGen.ar(Env.asr(10, 0.5, 5, 1, -4), doneAction: 2) * Pan2.ar(Saw.ar(~noteIn18 + 10, 0.2), -0.3)};
	~hIn18 = {EnvGen.ar(Env.asr(0.001, 0.3, 5, 0.6, -4), doneAction: 2) * Pan2.ar(RLPF.ar(Resonz.ar(SinOsc.ar(~noteIn18, 0.3), ~noteIn18, 0.8), ~noteIn18, 0.8) + RLPF.ar(Resonz.ar(BPF.ar(Saw.ar(~noteIn18, 0.15), ~noteIn18, 0.8), ~noteIn18, 0.8), ~noteIn18, 1), 1)};
	~iIn18 =  {EnvGen.ar(Env.asr(0.001, 0.8, 5, 1, -4), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn18 + 5, 0, 0.3), -1)};
	~jIn18 = {EnvGen.ar(Env.asr(0.001, 0.8, 5, 1, -4), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn18 + 10, 0, 0.3), 1)};
	~kIn18 =  {EnvGen.ar(Env.asr(0.01, 0.3, 5, 1, -4), doneAction: 2) * Pan2.ar(Saw.ar(~noteIn18 + 10, 0.3), 0)};

	//// 19
	~noteIn19 = ~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)].midicps;
	~sigIn19 = {EnvGen.kr(Env.new([0, 0.9, 0.9, 0.4, 0], [5, 2, 4, 1],[0, 0, 0]), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn19, 0, 0.3, 0), SinOsc.kr(0.1), 0.3)};

	//// 20
	~panArrIn20 = Array.fill(25, {rrand(-1.0, 1.0)});
	~transposeArrIn20 = Array.fill(25, {rrand(36, 48)});
	~patIn20 = Pbind(\instrument, Prand(["playRandNotesSine"], 25), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.008, \amp, 0.08, \ctranspose, Pseq(~transposeArrIn20), \pan, Pseq(~panArrIn20, 1));
	~transposeArrIn20_2 = Array.fill(25, {rrand(12, 48)});
	~patIn20_2 = Pbind(\instrument, Prand(["playRandNotesSine"], 25), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.008, \amp, 0.08, \ctranspose, Pseq(~transposeArrIn20_2), \pan, Pseq(~panArrIn20, 1));
	~panArrIn20_3 = Array.fill(375, {rrand(-1.0, 1.0)});
	~transposeArrIn20_3 = Array.fill(375, {rrand(-12, 48)});
	~patIn20_3 = Pbind(\instrument, Prand(["playRandNotesSine"], 375), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.004, \amp, 0.08, \ctranspose, Pseq(~transposeArrIn20_3), \pan, Pseq(~panArrIn20_3, 1));

	//// 21
	~noteIn21 = ~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)].midicps;
	~sigIn21 = {EnvGen.kr(Env.new([0, 1, 0.7, 0.7, 0], [0.5, 0.5, 1.95, 0.015],[0, -1, 0]), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn21 , 0, 0.3, 0), 0)};
	~panArrIn21 = Array.fill(125, {rrand(-1.0, 1.0)});
	~transposeArrIn21 = Array.fill(125, {rrand(-12, 24)});
	~patIn21 = Pbind(\instrument, Prand(["playRandNotesSaw"], 125), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.008, \amp, 0.3, \ctranspose, Pseq(~transposeArrIn21), \pan, Pseq(~panArrIn21, 1));
	// 3.2 seconds
	~noteIn21_2 = ~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)].midicps;
	~sigIn21_2 = {EnvGen.kr(Env.new([0, 0.3, 0.3, 1, 0.8, 0.8, 0], [0.01, 1.9, 0.1, 0.1, 2.01, 0.09],[0, 0, 5, 0, 0]), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn21_2 + 50, 0, 0.3, 0), 0)};
	// 2 seconds
	// pan from center to left and right at the same time
	~panArrIn21_2_L = Array.series(400, 0, -0.0025);
	~transposeArrIn21_2_L = Array.fill(400, {rrand(12, 48)});
	~patIn21_2_L = Pbind(\instrument, Prand(["playRandNotesSaw"], 400), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.005, \amp, 0.375, \ctranspose, Pseq(~transposeArrIn21_2_L, 1), \pan, Pseq(~panArrIn21_2_L, 1));
	~panArrIn21_2_R = Array.series(400, 0, 0.0025);
	~transposeArrIn21_2_R = Array.fill(400, {rrand(-12, 24)});
	~patIn21_2_R = Pbind(\instrument, Prand(["playRandNotesSine"], 400), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.005, \amp, 0.172, \ctranspose, Pseq(~transposeArrIn21_2_R, 1), \pan, Pseq(~panArrIn21_2_R, 1));
	~noteIn21_3 = ~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)].midicps;
	~sigIn21_8 = {EnvGen.kr(Env.new([0, 0.9, 0.9, 0], [0.1, 2.8, 0.1], [0, 0, 0]), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn21_3, 0, 0.3, 0), SinOsc.kr(0.35), 0.3)};
	~ampFadeIn21_8 = Array.series(2000, 0.2, -0.0001);
	~transposeArrIn21_3 = Array.fill(2000, {rrand(-12, 48)});
	~patIn21_3 = Pbind(\instrument, Prand(["playRandNotesSine"], 2000), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.002, \amp, Pseq(~ampFadeIn21_8, 1), \ctranspose, Pseq(~transposeArrIn21_3, 1), \pan, 0);

	///// 22
	~patIn22 = Pbind(\instrument, Prand(["playRandNotesSaw"], 3), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.068, \amp, 0.5, \ctranspose, 12, \pan, -0.65);
	~transposeArrIn22_2 = Array.fill(2, {rrand(1, 30)});
	~patIn22_2 = Pbind(\instrument, Prand(["playRandNotesSaw"], 2), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.068, \amp, 0.5, \ctranspose, Pseq(~transposeArrIn22_2, 1), \pan, 1);
	~transposeArrIn22_3 = Array.fill(7, {rrand(1, 23)});
	~patIn22_3 = Pbind(\instrument, Prand(["playRandNotesSaw"], 7), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.07, \amp, 0.5, \ctranspose, Pseq(~transposeArrIn22_3, 1), \pan, -1);
	~noteIn22 = ~midiBlock[rrand(0, 4)][rrand(0, 3)][rrand(0, 6)].midicps;
	~sigIn22_4 = {EnvGen.kr(Env.new([0, 1, 0.2, 0.08, 0], [0.01, 1, 3, 1],[0, -1.5, 0, -1]), doneAction: 2) * Pan2.ar(SinOsc.ar(~noteIn22, 0, 0.3, 0), Line.kr(1, -0.2, 4.5))};

	//// 23
	~aIn23 = {EnvGen.ar(Env.asr(10, 0.6, 5, 1, -4), doneAction: 2) * Pan2.ar(SinOsc.ar(XLine.kr(10000, 150, 10), 0,  0.02), 0)};

	//// 24
	~patIn24_1 = Pbind(\instrument, Prand(["playRandNotesSine"], 8), \midinote, Pfunc({
		(~filterNote.() ).postln; // change the number of notes output in Prand
	}), \dur, 0.048, \amp, 0.05, \ctranspose, 24, \pan, 1);
	~patIn24_2 = Pbind(\instrument, Prand(["playRandNotesSaw"], 8), \midinote, Pfunc({
		(~filterNote.()).postln;
	}), \dur, 0.033, \amp, 0.25, \ctranspose, -12, \pan, -1);
	~patIn24_3 = Pbind(\instrument, Prand(["playRandNotesSine"], 8), \midinote, Pfunc({
		(~filterNote.() ).postln; // change the number of notes output in Prand
	}), \dur, 0.048, \amp, 0.05, \ctranspose, 12, \pan, 1);
	~patIn24_4 = Pbind(\instrument, Prand(["playRandNotesSaw"], 8), \midinote, Pfunc({
		(~filterNote.()).postln;
	}), \dur, 0.033, \amp, 0.25, \ctranspose, 36, \pan, -1);
	~patIn24_5 = Pbind(\instrument, Prand(["playRandNotesSine"], 16), \midinote, Pfunc({
		(~filterNote.() ).postln; // change the number of notes output in Prand
	}), \dur, 0.048, \amp, 0.05, \ctranspose, 1, \pan, 0);
	~patIn24_6 = Pbind(\instrument, Prand(["playRandNotesSaw"], 16), \midinote, Pfunc({
		(~filterNote.()).postln;
	}), \dur, 0.033, \amp, 0.25, \ctranspose, 36, \pan, 0);

	//// 25
	~ampArrIn25 = Array.series(1000, 0, 0.0003);
	~transposeArrIn25 = Array.series(5000, -12, 0.0048);
	~patIn25 = Pbind(\instrument, Prand(["playRandNotesSine"], 5000), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.015, \amp, Pseq(~ampArrIn25, 1), \ctranspose, Pseq(~transposeArrIn25, 1), \pan, 0);

	//// 26
	~patIn26 = Pbind(\instrument, Prand(["playRandNotesSine"], 130), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.01, \amp, 0.08, \ctranspose, 30, \pan, 0);

	~panArrIn26_2 = Array.series(260, -1, 0.0075);
	~patIn26_2 = Pbind(\instrument, Prand(["playRandNotesSine"], 260), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.01, \amp, 0.08, \ctranspose, 12, \pan, Pseq(~panArrIn26_2, 1));

	~panArrIn26_3 = Array.series(130, 1, -0.0075);
	~patIn26_3 = Pbind(\instrument, Prand(["playRandNotesSine"], 130), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.01, \amp, 0.08, \ctranspose, 12, \pan, Pseq(~panArrIn26_3, 1));

	//// 27
	// 18 seconds of random panning and notes
	~ampIn27 = Array.fill(900, {(rrand(0.05, 0.2)).trunc(0.001) });
	~ampDecreIn27 = Array.fill(900, { arg i; -0.00022222 * i });
	~newAmpIn27 = ~ampTestIn27 ++ ~ampDecreIn27;
	~transposeArrIn27 = Array.fill(900, {rrand(-12, 36)});
	~panArrIn27_1 = Array.fill(900, {rrand(-1.0, 1.0)});
	~patIn27 = Pbind(\instrument, Prand(["playRandNotesSine"], 900), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.02, \amp, Pseq(~newAmpIn27, 1), \ctranspose, Pseq(~transposeArrIn27, 1), \pan, Pseq(~panArrIn27_1, 1));
	// fade out chunk; 5 seconds
	~ampFadeIn27 = Array.series(250, 0.08, -0.00032);
	~panArrIn27_2 = Array.fill(250, {rrand(-1.0, 1.0)});
	~patIn27_2 = Pbind(\instrument, Prand(["playRandNotesSine"], 250), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.02, \amp, Pseq(~ampFadeIn27, 1), \ctranspose, Pseq(~transposeArrIn27, 1), \pan, Pseq(~panArrIn27_2, 1));

	//// 28
	~transposeArrIn28 = Array.fill(2000, {2000.linrand});
	~ampArrIn28 =  Array.series(2000, 0.08, -0.00004);
	~patIn28 = Pbind(\instrument, Prand(["playRandNotesSine"], 2000), \midinote, Pfunc({
		(~filterNote.() ).postln;
	}), \dur, 0.02, \amp, Pseq(~ampArrIn28, 1), \ctranspose, Pseq(~transposeArrIn28, 1), \pan, 0);

}; // wait for boot

)




////////////////////////////////// BEGIN //////////////////////////////////

//// 1
// fast runs, pan from L to R without slowly down or fadeout;
Pdef(\1, ~patIn1);



//// 2
// fast, short gesture, middle, don't slow down; p; app 3 sec
Pdef(\2, Ppar([~patIn2_1, ~patIn2_2], 1) );



//// 3
// another short gesture, L; mf; app 3 sec
Pdef(\3, Ppar([~patIn3_1, ~patIn3_2], 1) ); // output each pattern to each L and R speaker



//// 4
// fast to slow gestural runs; from R to L; longer than 1; ff -> pppp; app 7 sec
Pdef(\4, ~patIn4);



//// 5
// slow to fast runs; L to R; loud to quiet
(
Ndef(\5).play;
{
	var tempo = 1;
	~panArr = Array.series(120, -1, 0.02);
	~ampArr = Array.series(120, 0.8, -0.00534);

	Ndef(\5).fadeTime = 0.01; // fade in duration; cross this out will have about 1 second of fade in
	Ndef(\5, Pdef(\pat5) ); // assign \26 to \pattPlay
	TempoClock.tempo = tempo; // set the current system tempo

	~patIn5 = Pbind(\instrument, Prand(["playRandNotesSaw"], inf), \midinote, Pfunc({ (~filterNote.() );
	}), \dur, 0.06, \amp, Pseq(~ampArr, 1), \ctranspose, 12, \pan, Pseq(~panArr, 1));

	Pdef(\pat5, ~patIn5);

	5.yield; //wait for 5 seconds for the above to finish playing and then run the rest of the code to fade out
	"fadeout".postln;

	Ndef(\5).fadeTime = 2; // duration of second part of this stream, refer to the fade out part
	Ndef(\5, {}); // run \pattPlay again for this fade out part

	10.do { // 10 times of -0.1 to slow down; count down from 1 second and then -0.1 each repetition
		TempoClock.tempo = tempo.postln; // set a new system tempo by using .tempo; default is beat per second
		tempo = tempo - 0.1; // increase duration between notes to rit (-0.1); decrease duration between notes to accel (+0.1 or more)
		0.1.yield; // give each beat 0.1 second
	}

}.fork; // entire thing as a stream
)

// reset tempo so the other effects will play at the right speed
(
Ndef(\5).clear;
TempoClock.tempo = 1;
)



//// 6
(
~routineIn6 = Routine {
	~ndef_a = Ndef(\a, ~a).play;
	3.yield;
	~ndef_b = Ndef (\b, ~b).play;
	5.yield;
	~ndef_c = Ndef (\c, ~c).play;
	2.yield;
	~ndef_b.release(5);
	~ndef_b.stop(6);
	10.yield;
	~ndef_c.release(5);
	~ndef_c.stop(6);
	12.yield;
	~ndef_a.release(3);
	~ndef_a.stop(4);
}.play;
)



//// 7
(
Ndef(\7).play;
{
	var tempo = 1;
	~panArr = Array.series(120, 1, 0.02);
	~ampArr = Array.series(120, 0.8, 0.00534);
	Ndef(\7).fadeTime = 0.01; // fade in duration; cross this out will have about 1 second of fade in
	Ndef(\7, Pdef(\pat7) ); // assign \26 to \pattPlay
	TempoClock.tempo = tempo; // set the current system tempo
	~patIn7 = Pbind(\instrument, Prand(["playRandNotesSaw"], inf), \midinote, Pfunc({ (~filterNote.() );
	}), \dur, 0.08, \amp, Pseq(~ampArr, 1), \ctranspose, 12, \pan, Pseq(~panArr, 1));
	Pdef(\pat7, ~patIn7).play;
	2.yield; //wait for 5 seconds for the above to finish playing and then run the rest of the code to fade out
	"fadeout".postln;
	Ndef(\7).fadeTime = 2; // duration of second part of this stream, refer to the fade out part
	Ndef(\7, {}); // run \pattPlay again for this fade out part
	10.do { // 10 times of -0.1 to slow down; count down from 1 second and then -0.1 each repetition
		TempoClock.tempo = tempo.postln; // set a new system tempo by using .tempo; default is beat per second
		tempo = tempo + 3; // increase duration between notes to rit (-0.1); decrease duration between notes to accel (+0.1 or more)
		0.1.yield; // give each beat 0.1 second
	};
}.fork; // entire thing as a stream
)

// reset tempo so the other effects will play at the right speed
(
Ndef(\7).clear;
TempoClock.tempo = 1;
)



//// 8
(
Ndef(\8).play;
{
	var tempo = 1;
	~panArr = Array.series(120, -0.25, 0.025);
	~ampArr = Array.series(120, 0.55, -0.0041);
	Ndef(\8).fadeTime = 0.01; // fade in duration; cross this out will have about 1 second of fade in
	Ndef(\8, Pdef(\pat8) ); // assign \26 to \pattPlay
	TempoClock.tempo = tempo; // set the current system tempo
	~patIn8 = Pbind(\instrument, Prand(["playRandNotesSaw"], inf), \midinote, Pfunc({ (~filterNote.() );
	}), \dur, 0.075, \amp, Pseq(~ampArr, 1), \ctranspose, 12, \pan, Pseq(~panArr, 1));
	Pdef(\pat8, ~patIn8);
	5.yield; //wait for 5 seconds for the above to finish playing and then run the rest of the code to fade out
	"fadeout".postln;
	Ndef(\8).fadeTime = 2; // duration of second part of this stream, refer to the fade out part
	Ndef(\8, {}); // run \pattPlay again for this fade out part
	10.do { // 10 times of -0.1 to slow down; count down from 1 second and then -0.1 each repetition
		TempoClock.tempo = tempo.postln; // set a new system tempo by using .tempo; default is beat per second
		tempo = tempo - 0.1; // increase duration between notes to rit (-0.1); decrease duration between notes to accel (+0.1 or more)
		0.1.yield; // give each beat 0.1 second
	}
}.fork; // entire thing as a stream
)
// reset tempo so the other effects will play at the right speed
(
Ndef(\8).clear;
TempoClock.tempo = 1;
)



//// 9
(
~routineIn9 = Routine {
	~ndef_in9 = Ndef(\ndef_in9, ~a9).play;
	3.yield;
	~ndef_in9.release(7);
	~ndef_in9.stop(8);
	5.yield;
	~play1 = ~playShep1.(0.03, 0.75,  0,  0);
	~play2 = ~playShep2.(0.03, 0.75,  1,  0);
	0.5.yield;
	Ndef(\shepStream1).free(17);
	Ndef(\shepStream2).free(17);
	Ndef(\shepStream1).stop(18);
	Ndef(\shepStream2).stop(18);
}.play;
)





//// 10
(
~rIn10 = Routine {
	Pdef(\10).play;
	12.yield;
	Pdef(\102).play;
}.play;
)



//// 11
// swipe
Pdef(\11).play;



//// 12
// swipe
Pdef(\12).play;



//// 13
/// short duration figures
Pdef(\13).play;



//// 14
/// short duration figures
Pdef(\14).play;



//// 15
/// short duration figures
Pdef(\15).play;



//// 16
// from left to right, fast runs, develope from the above figures
Pdef(\16).play;



///// 17
(
~routineIn17 = Routine {
	Pdef(\17).play;
	4.yield;
	Pdef(\172).play;
	6.8.yield;
	Pdef(\173).play;
	7.8.yield;
	Pdef(\174).play;
	18.5.yield;
	Pdef(\175).play;
}.play;
)



//// 18
(
~routineIn18 = Routine {
	~ndef_aIn18 = Ndef (\ndef_aIn18, ~aIn18).play;
	2.5.yield;
	~ndef_bIn18 = Ndef (\ndef_bIn18, ~bIn18).play;
	5.yield;
	~ndef_bIn18.release(8);
	~ndef_bIn18.stop(9);
	~ndef_cIn18 = Ndef (\ndef_cIn18, ~cIn18).play;
	6.yield;
	~ndef_aIn18.release(2);
	~ndef_aIn18.stop(3);
	~ndef_bIn18 = Ndef (\ndef_bIn18, ~bIn18).play;
	5.yield;
	~ndef_cIn18.release(5);
	~ndef_cIn18.stop(6);
	~ndef_dIn18 = Ndef (\ndef_dIn18, ~dIn18).play;
	3.yield;
	~ndef_eIn18 = Ndef (\ndef_eIn18, ~eIn18).play;
	8.yield;
	~ndef_bIn18.release(8);
	~ndef_bIn18.stop(9);
	~ndef_dIn18.release(8);
	~ndef_dIn18.stop(9);
	~ndef_eIn18.release(10);
	~ndef_eIn18.stop(11);
	~ndef_fIn18 = Ndef (\ndef_fIn18, ~fIn18).play;
	2.yield;
	~ndef_gIn18 = Ndef (\ndef_gIn18, ~gIn18).play;
	7.5.yield;
	~ndef_hIn18 = Ndef (\ndef_hIn18, ~hIn18).play;
	1.yield;
	~ndef_fIn18.release(8);
	~ndef_fIn18.stop(9);
	~ndef_iIn18 = Ndef (\ndef_iIn18, ~iIn18).play;
	1.yield;
	~ndef_jIn18 = Ndef (\ndef_jIn18, ~jIn18).play;
	1.yield;
	~ndef_kIn18 = Ndef (\ndef_kIn18, ~kIn18).play;
	3.yield;
	~ndef_hIn18.release(6);
	~ndef_hIn18.stop(7);
	~ndef_iIn18.release(5);
	~ndef_iIn18.stop(6);
	9.yield;
	~ndef_gIn18.release(1);
	~ndef_gIn18.stop(2);
	~ndef_jIn18.release(1);
	~ndef_jIn18.stop(2);
	~ndef_kIn18.release(1);
	~ndef_kIn18.stop(2);
}.play;
)



//// 19
~sigIn19.play;



//// 20
(
~routineIn20 = Routine {
	~patIn20.play;
	1.yield;
	~patIn20_2.play;
	1.yield;
	~patIn20_3.play;
	2.yield;
}.play;
)



//// 21
(
~routineIn21 = Routine {
	~sigIn21.play;
	3.yield;
	~patIn21.play;
	1.yield;
	~sigIn21_2.play;
	4.yield;
	~patIn21_2_L.play;
	~patIn21_2_R.play;
	2.yield;
	~sigIn21.play;
	3.5.yield;
	~patIn21_3.play;
	4.yield;
	3.yield;
}.play;
)



///// 22
(
~routineIn22 = Routine {
	~patIn22.play;
	2.yield;
	~patIn22_2.play;
	2.yield;
	~patIn22_3.play;
	1.yield;
	~sigIn22_4.play;
}.play;
)



//// 23
(
~routineIn23 = Routine {
	~ndef_aIn23 = Ndef(\aIn23, ~aIn23).play;
	10.yield;
	~ndef_aIn23.release(5);
	~ndef_aIn23.stop(6);
}.play;
)



//// 24
(
~routineIn24 = Routine {
	Pdef(\24, Ppar([~patIn24_1, ~patIn24_2], 1) ).play;
	2.yield;
	Pdef(\241, Ppar([~patIn24_3, ~patIn24_4], 1) ).play;
	2.yield;
	Pdef(\242, Ppar([~patIn24_5, ~patIn24_6], 1) ).play;
};
~routineIn24.play;
)



//// 25
Pdef(\25, ~patIn25).play;



//// 26
(
~routineIn26 = Routine {
	~patIn26.play;
	3.yield;
	~patIn26_2.play;
	2.6.yield;
	~patIn26_3.play;
}.play;
)



//// 27
(
~routineIn27 = Routine {
	~patIn27.play;
	18.yield;
	~patIn27_2.play;
}.play;
)



//// 28
~patIn28.play;



////////////////////////////////// END //////////////////////////////////
