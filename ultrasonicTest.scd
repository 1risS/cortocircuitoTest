SerialPort.devices

~port = SerialPort.new("/dev/ttyUSB0", 9600);

(
x = [ ];
30.do{x = x.add(~port.read)};
x = x.collect(_.asAscii)
)

~port.close;

(
p = SerialPort(
  "/dev/ttyUSB0",
  baudrate: 9600,
  crtscts: true
);
)

(
r= Routine({
    var byte, str, res;
    99999.do{|i|
        if(p.read==10, {
            str = "";
            while({byte = p.read; byte !=13 }, {
                str= str++byte.asAscii;
            });
            ~res = str.asInteger;
			// ("read value:"+res).postln;
        });
    };
}).play;
)

~res

(
SynthDef.new(\saw, {
	| cutoff = 1000|
	var sig;

	sig = Saw.ar([50,51]);
	sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, 0.2);
	Out.ar(0, sig);
}).add
)

~synth = Synth(\saw, [\cutoff, 200]);

~synth.set(\cutoff, ~res*200)

~synth.free


(
~control = Routine.new({
  {
    ~synth.set(\cutoff, ~res.linexp(0, 1023, 80, 4000));
    0.01.wait;
  }.loop;
}).play;
)


r.stop;
p.close;