

(
{
	var humSource, noise, comb;

	humSource = Clip.ar(LFSaw.ar([99.8, 100.2], 1, 0.5, 0.5).sum - 1, -0.5, 0.5);

	noise = LPF.ar(LPF.ar(WhiteNoise.ar,2),2);
	noise = noise * noise * 500;

	humSource = humSource * noise;

	comb = DelayC.ar(InFeedback.ar(10), delaytime: (noise+20)/1000);
	OffsetOut.ar(10, (humSource + OnePole.ar(comb * 0.2, exp(-2pi * (3000 * SampleDur.ir)))));

	comb!2 ;

}.play;
)


(
{
	var noise, phasor, chirpPulse, randGate, chirpAmp, clip, snap, trig, formant, comb;

	phasor = LFSaw.ar([-99.8, 100.2], 1, 0.5, 0.5);

	noise = WhiteNoise.ar!2;
	noise[0] = OnePole.ar(noise[0], exp(-2pi * (0.1 * SampleDur.ir)));
	noise[0] = OnePole.ar(noise[0], exp(-2pi * (0.1 * SampleDur.ir)));
	noise[0] = noise[0].max(0) * 700 + 3;


	chirpPulse = phasor[0].scope * noise[0];
	chirpPulse = chirpPulse.min(1) - (chirpPulse.max(1) - 1 * 1e+09).min(1);
	chirpPulse.scope;
	chirpPulse = ((chirpPulse + 0.1)**2 * 12 * 2pi).cos * chirpPulse;
	chirpPulse.scope;
	chirpPulse = (chirpPulse - OnePole.ar(chirpPulse, exp(-2pi * (300 * SampleDur.ir))));

	randGate = WhiteNoise.ar;
	randGate = OnePole.ar(randGate, exp(-2pi * (3 * SampleDur.ir)));
	randGate = OnePole.ar(randGate, exp(-2pi * (3 * SampleDur.ir)));
	randGate = Clip.ar(noise.max(2) - 0.0008 * 1e+09, 0, 1);
	randGate = OnePole.ar(randGate, exp(-2pi * (30 * SampleDur.ir)));
	randGate = chirpPulse * randGate;


	noise[1] = LPF.ar(LPF.ar(WhiteNoise.ar,2),2);
	noise[1] = noise[1] * noise[1] * 500;


	clip = Clip.ar((phasor.sum - 1) * noise[1], -0.9, 0.1);


	chirpAmp = OnePole.ar(clip, exp(-2pi * (15 * SampleDur.ir)));
	chirpAmp = OnePole.ar(chirpAmp, exp(-2pi * (15 * SampleDur.ir)));
	chirpAmp = Clip.ar((chirpAmp * 500).max(0.1) - 0.1 * 1e+09, 0, 1);
	chirpAmp = OnePole.ar(chirpAmp, exp(-2pi * (30 * SampleDur.ir)));


	chirpPulse = chirpPulse * chirpAmp * 0.6;
	trig = (Amplitude.kr(clip)>0.03);


	snap = 0!2;
	snap[0] = EnvGen.ar(Env.new([0,1,0], [0, 0.5]), trig);
	snap[0] = snap[0] * snap[0] * snap[0] * WhiteNoise.ar * 0.5;
	snap[1] = EnvGen.ar(Env.new([0,1,0], [0, 10/1000]), trig);
	snap[1] = SinOsc.ar(snap[1] * 7000 + 20);
	snap = snap.sum * 0.05;


	formant = BPF.ar(snap, 1.8 * [4600, 7200, 480, 720], [5,5,7,8].reciprocal);
	formant = formant[0..1].sum * 2 + formant[2] * 1.2 + formant[3] * 2.5;
	formant = BPF.ar(formant, 2500, 0.5.reciprocal);



	comb = DelayC.ar(InFeedback.ar(10), delaytime: (noise[1] + 20)/1000);
	OffsetOut.ar(10, (chirpPulse + clip + snap + OnePole.ar(comb * 0.2, exp(-2pi * (3000 * SampleDur.ir)))));

	comb!2;

}.play;
)

s.StopRecording;
