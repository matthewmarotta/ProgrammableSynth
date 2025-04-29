import java.util.Arrays;
import controlP5.*;

ControlP5 controlP5;

import themidibus.*;
import beads.*;

Gain g;

float pitch;

AudioContext ac;
GranularSamplePlayer sp;
Glide delayGlide;
TapIn tin;
TapOut tout;
Gain gDelay;

MidiBus myBus;

Envelope pitchEnvelope;
Envelope pitchEnvelope2;

Knob volume;
Knob reverbSize;
Knob reverbDamping;
Knob reverbEarlyReflections;
Knob reverbLateReflections;

Knob delayTime;
Knob delayGain;

float playbackRate;

Reverb r;

void setup() {
  size(1000, 1000);
  background(0);
  smooth();

  //Code for Volume Knob
  controlP5 = new ControlP5(this);

  volume = controlP5.addKnob("volume", 0, 1, 0, 40, 30, 120);
  reverbSize = controlP5.addKnob("reverbSize", 0.0, 1.0, 0.0, 200, 30, 120);
  reverbDamping = controlP5.addKnob("reverbDamping", 0.0, 1.0, 0.0, 360, 30, 120);
  reverbEarlyReflections = controlP5.addKnob("reverbEarlyReflections", 0.0, 1.0, 0.0, 520, 30, 120);
  reverbLateReflections = controlP5.addKnob("reverbLateReflections", 0.0, 1.0, 0.0, 680, 30, 120);
  
  delayTime = controlP5.addKnob("delayTime", 0.1, 0.8, 0.0, 40, 180, 120);
  delayGain = controlP5.addKnob("delayGain", 0.0, 1.0, 0.0, 200, 180, 120);

  //Sets value for noteOFF (value of previous key when another midi key is pressed)
  pitchEnvelope2 = new Envelope(0);

  //Links the midi controler
  MidiBus.list();
  myBus = new MidiBus(this, 1, "");
  ac = AudioContext.getDefaultContext();
  selectInput("Select an audio file:", "fileSelected");
}

void draw() {
}
color fore = color(92, 169, 250);
color back = color(0, 0, 0);

void fileSelected(File selection) {

  String audioFileName = selection.getAbsolutePath();
  Sample sample = SampleManager.sample(audioFileName);



  sp = new GranularSamplePlayer(sample);

  //Ensures sample plays once only per keypress
  sp.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
  //Allows the sample to be played more than once
  sp.setKillOnEnd(false);

  //Delay (parameters can be changed to edit the sound)
  tin = new TapIn(ac, 1000);  // buffer size: 1000 ms
  delayGlide = new Glide(ac, 250); // default delay = 500ms
  tout = new TapOut(ac, tin, delayGlide); // pass the Glide as the delay value
  gDelay = new Gain(ac, 2, 0.3);
  gDelay.addInput(tout);
  tin.addInput(gDelay);
  tin.addInput(sp);

  //Reverb (parameters can be changed to edit the sound)
  r = new Reverb(ac, 1);

  //gain
  g = new Gain(ac, 2, 0.2);
  g.addInput(sp);
  g.addInput(tout);
  r.addInput(g);
  g.addInput(sp);
  ac.out.addInput(r);
  ac.out.addInput(g);
  ac.start();
}

//noteOn means what happens when a key has been pressed
void noteOn(int channel, int pitch, int velocity) {
  //algorithm: value 2 dictates the amount of semitones the sample goes up by, 1 being no semitones
  //(pitch % 24) changes where it loops back to the original tone of the sample i.e after 24 keys
  //12f is the amount of divisions there are per octave
  float playBackRate = (pow(2, (pitch % 24) / 12f));
  sp.getPitchUGen().setValue(playBackRate);
  //sets sample back to the start each time a new key gets pressed
  sp.setPosition(0);
}
//noteOff means what happens when a subsequent key has been pressed
void noteOff(int channel, int pitch, int velocity) {
  sp.setPitch(pitchEnvelope2);
}

//sets a gain for the volume knob
void volume(float theValue) {
  if (g != null) {
    g.setGain(theValue);
  }
}

void reverbSize(float theValue) {
  if (r != null) {
    r.setSize(theValue);
  }
}

void reverbDamping(float theValue) {
  if (r != null) {
    r.setDamping(theValue);
  }
}

void reverbEarlyReflections(float theValue) {
  if (r != null) {
    r.setEarlyReflectionsLevel(theValue);
  }
}

void reverbLateReflections(float theValue) {
  if (r != null) {
    r.setLateReverbLevel(theValue);
  }
}

void delayTime(float theValue) {
  if (delayGlide != null) {
    delayGlide.setValue(theValue * 1000);
  }
}

void delayGain(float theValue) {
  if (gDelay != null) {
    gDelay.setGain(theValue);
  }
}
