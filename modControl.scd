(
SynthDef.new(\modu, { |out = 0, sawFq = 300, sinFq = 200 |
	var sig1, sig2, sig;

	sig1 = Saw.ar([sawFq, sawFq * 1.25]);

	sig2 = SineShaper.ar(SinOsc.ar([sinFq, sinFq*0.9], 0, 0.2, 1), MouseX.kr(0, 0.3));

	sig = RLPF.ar(sig1, 200, 1.2, 1, 1)*sig2;

	Out.ar(out, Pan2.ar(sig));

}).add
)

s.record;
s.stopRecording;

~modu = Synth(\modu);

