//
//  SynthOne.swift
//  load an AudioKit SynthOne preset from JSON and use a subset of those parameters
//  to create an audio engine that can play back the instrument, with MIDI note controls
//
//
//  Created by Jared Updike on 7/10/24.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

let myStr = """
{
"adsrPitchTracking": 0,
"arpDirection": 0,
"arpInterval": 3,
"arpIsSequencer": true,
"arpOctave": 1,
"arpRate": 99,
"arpSeqTempoMultiplier": 0.25,
"arpTotalSteps": 16,
"attackDuration": 0.0005000000237487257,
"author": "",
"autoPanAmount": 0.014222183264791965,
"autoPanFrequency": 0.20625001192092896,
"bank": "BankA",
"bitcrushLFO": 0,
"category": 1,
"compressorMasterAttack": 0.0010000000474974513,
"compressorMasterMakeupGain": 2,
"compressorMasterRatio": 20,
"compressorMasterRelease": 0.15000000596046448,
"compressorMasterThreshold": -9,
"compressorReverbInputAttack": 0.0010000000474974513,
"compressorReverbInputMakeupGain": 1.8799999952316284,
"compressorReverbInputRatio": 13,
"compressorReverbInputRelease": 0.22499999403953552,
"compressorReverbInputThreshold": -8.5,
"compressorReverbWetAttack": 0.0010000000474974513,
"compressorReverbWetMakeupGain": 1.8799999952316284,
"compressorReverbWetRatio": 13,
"compressorReverbWetRelease": 0.15000000596046448,
"compressorReverbWetThreshold": -8,
"crushFreq": 48000,
"cutoff": 8419.37890625,
"cutoffLFO": 1,
"decayDuration": 0.5167812705039978,
"decayLFO": 0,
"delayFeedback": 0.10000000149011612,
"delayInputCutoffTrackingRatio": 0.75,
"delayInputResonance": 0,
"delayMix": 0.171875,
"delayTime": 0.3030302822589874,
"delayToggled": 0,
"detuneLFO": 1,
"filterADSRMix": 0.8928000330924988,
"filterAttack": 0.0005000000237487257,
"filterDecay": 0.39729341864585876,
"filterEnvLFO": 0,
"filterRelease": 0.15649987757205963,
"filterSustain": 0,
"filterType": 0,
"fmAmount": 0.10666580498218536,
"fmLFO": 0,
"fmVolume": 0.052148208022117615,
"frequencyA4": 440,
"glide": 0,
"isArpMode": 0,
"isFavorite": true,
"isHoldMode": 0,
"isLegato": 0,
"isMono": 0,
"isUser": true,
"lfo2Amplitude": 0.8366659879684448,
"lfo2Rate": 0.13750001788139343,
"lfo2Waveform": 0,
"lfoAmplitude": 0.4962500035762787,
"lfoRate": 0.4125000238418579,
"lfoWaveform": 0,
"masterVolume": 0.6550000309944153,
"midiBendRange": 2,
"modWheelRouting": 0,
"name": "Totally Tubular JFU 2",
"noiseLFO": 0,
"noiseVolume": 0,
"octavePosition": 0,
"oscBandlimitEnable": 0,
"oscMixLFO": 0,
"phaserFeedback": 0,
"phaserMix": 0,
"phaserNotchWidth": 800,
"phaserRate": 12,
"pitchLFO": 0,
"pitchbendMaxSemitones": 12,
"pitchbendMinSemitones": -12,
"position": 48,
"releaseDuration": 0.39031898975372314,
"resonance": 0.10000000149011612,
"resonanceLFO": 0,
"reverbFeedback": 0.6196499466896057,
"reverbHighPass": 442.3374938964844,
"reverbMix": 0.11000000685453415,
"reverbMixLFO": 0,
"reverbToggled": 0,
"subOsc24Toggled": 0,
"subOscSquareToggled": 0,
"subVolume": 0.40087035298347473,
"sustainLevel": 0.014222259633243084,
"tempoSyncToArpRate": 1,
"transpose": 0,
"tremoloLFO": 0,
"tuningName": "12 ET",
"uid": "5339E394-AA19-4FA5-B885-A807FA0D52C1",
"vco1Semitone": 0,
"vco1Volume": 0.800000011920929,
"vco2Detuning": 0.9399999976158142,
"vco2Semitone": 12,
"vco2Volume": 0.800000011920929,
"vcoBalance": 0,
"waveform1": 0.25,
"waveform2": 0.28738316893577576,
"widen": 0
}
""";

//"waveform1": 0.25,
//"waveform2": 0.28738316893577576,


struct Synth1Preset: Decodable {
    let adsrPitchTracking: Float
    let attackDuration: Float // seconds?
//    "compressorMasterAttack": 0.0010000000474974513,
//    "compressorMasterMakeupGain": 2,
//    "compressorMasterRatio": 20,
//    "compressorMasterRelease": 0.15000000596046448,
//    "compressorMasterThreshold": -9,
//    "compressorReverbInputAttack": 0.0010000000474974513,
//    "compressorReverbInputMakeupGain": 1.8799999952316284,
//    "compressorReverbInputRatio": 13,
//    "compressorReverbInputRelease": 0.22499999403953552,
//    "compressorReverbInputThreshold": -8.5,
//    "compressorReverbWetAttack": 0.0010000000474974513,
//    "compressorReverbWetMakeupGain": 1.8799999952316284,
//    "compressorReverbWetRatio": 13,
//    "compressorReverbWetRelease": 0.15000000596046448,
//    "compressorReverbWetThreshold": -8,
    let cutoff: Float // frequency in Hz
    let cutoffLFO: Float
    let decayDuration: Float // seconds?
//    "decayLFO": 0,
//    "delayFeedback": 0.10000000149011612,
//    "delayInputCutoffTrackingRatio": 0.75,
//    "delayInputResonance": 0,
//    "delayMix": 0.171875,
//    "delayTime": 0.3030302822589874,
//    "delayToggled": 0,
//    "detuneLFO": 1,
    let filterADSRMix: Float
    let filterAttack: Float
    let filterDecay: Float
//    "filterEnvLFO": 0,
    let filterRelease: Float
    let filterSustain: Float
    let filterType: Int // ?
    let fmAmount: Float
//    fmLFO: 0,
    let fmVolume: Float
//    "lfo2Amplitude": 0.8366659879684448,
//    "lfo2Rate": 0.13750001788139343,
//    "lfo2Waveform": 0,
//    "lfoAmplitude": 0.4962500035762787,
//    "lfoRate": 0.4125000238418579,
//    "lfoWaveform": 0,
    let masterVolume: Float
//    "midiBendRange": 2,
//    "modWheelRouting": 0,
    let name: String
//    "noiseLFO": 0,
    let noiseVolume: Float
//    "octavePosition": 0,
    let oscBandlimitEnable: Int // 0 or 1, really a boolean
//    "oscMixLFO": 0,
//    "phaserFeedback": 0,
//    "phaserMix": 0,
//    "phaserNotchWidth": 800,
//    "phaserRate": 12,
//    "pitchLFO": 0,
//    "pitchbendMaxSemitones": 12,
//    "pitchbendMinSemitones": -12,
//    "position": 48,
    let releaseDuration: Float // seconds
    let resonance: Float
//    "resonanceLFO": 0,
//    "reverbFeedback": 0.6196499466896057,
//    "reverbHighPass": 442.3374938964844,
//    "reverbMix": 0.11000000685453415,
//    "reverbMixLFO": 0,
//    "reverbToggled": 0,
    let subOsc24Toggled: Int
    let subOscSquareToggled: Int
    let subVolume: Float // 0.0 to 1.0
    let sustainLevel: Float // 0.0 to 1.0, a percentage of initial velocity
//    "tremoloLFO": 0,
    let vco1Semitone: Int
    let vco1Volume: Float
    let vco2Detuning: Float
    let vco2Semitone: Int
    let vco2Volume: Float
    let vcoBalance: Float // -1 to 1? set to 0 in center?
    let waveform1: Float // 0.0 to 1.0, not  0.0 to 3.0 like MorphinOscillator, which is an easy conversion
    let waveform2: Float // same range
    
    var subOscIs24: Bool { subOsc24Toggled > 0 }
    var subOscIsSquare: Bool { subOscSquareToggled > 0 }
}

class S1GeneratorBank: ObservableObject, HasAudioEngine {
    public var engine = AudioEngine()
    var vco1 = MorphingOscillator()
    var vco2 = MorphingOscillator()
    var vco1Mixer: Mixer
    var vco2Mixer: Mixer
    var mixer: Mixer
    var dryWetMix: DryWetMixer
    
    var vco2SemiTonesOffset: Int8
    
    func noteOn(pitch: Pitch, point _: CGPoint) {
        isPlaying = true
        vco1.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
        //vco1.amplitude = // TODO point.whatever
        vco2.frequency = AUValue(pitch.midiNoteNumber + vco2SemiTonesOffset).midiNoteToFrequency()
        //vco2.amplitude = // TODO point.whatever
    }

    func noteOff(pitch _: Pitch) {
        isPlaying = false
    }
    
    //public parameters: NodeParameter

    @Published var isPlaying: Bool = false {
        didSet {
            if(isPlaying) {
                vco1.start()
                vco2.start()
            }
            else {
                vco1.stop()
                vco2.stop()
            }
        }
    }

    init(_ synth1Preset: Synth1Preset) {
        vco1.amplitude = synth1Preset.vco1Volume
        vco1.index = synth1Preset.waveform1 * 3.0
        vco1Mixer = Mixer(vco1)
        vco1Mixer.volume = synth1Preset.vco1Volume
        
        vco2.amplitude = synth1Preset.vco2Volume
        vco2.index = synth1Preset.waveform2 * 3.0
        vco2.detuningOffset = synth1Preset.vco2Detuning
        vco2SemiTonesOffset = Int8(synth1Preset.vco2Semitone)
        vco2Mixer = Mixer(vco2)
        vco2Mixer.volume = synth1Preset.vco2Volume
        
        dryWetMix = DryWetMixer(vco1Mixer, vco2Mixer, balance: AUValue(synth1Preset.vcoBalance))
        
        mixer = Mixer(vco1Mixer, vco2Mixer)
        mixer.volume = 0.2 // TODO deal with the fact this is so loud but we don't want to blow out our ears testing
        engine.output = mixer
    }
}

class SynthOneConductor: ObservableObject, HasAudioEngine {
    var engine = AudioEngine()
    var osc: S1GeneratorBank

    func noteOn(pitch: Pitch, point: CGPoint) {
        isPlaying = true
        osc.noteOn(pitch: pitch, point: point)
    }

    func noteOff(pitch: Pitch) {
        osc.noteOff(pitch: pitch)
    }

    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? osc.start() : osc.stop() }
    }

    init() {
        let jsonData = myStr.data(using: .utf8)!
        let synth1Preset: Synth1Preset = try! JSONDecoder().decode(Synth1Preset.self, from: jsonData)
        print("synth1Preset: \(synth1Preset)")
        osc = S1GeneratorBank(synth1Preset)
        engine = osc.engine
    }
}

struct SynthOneView: View {
    @StateObject var conductor = SynthOneConductor()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isPlaying.toggle()
            }
//            HStack {
//                ForEach(conductor.osc.parameters) {
//                    ParameterRow(param: $0)
//                }
//            }

            //NodeOutputView(conductor.osc)
            CookbookKeyboard(noteOn: conductor.noteOn,
                             noteOff: conductor.noteOff)
        }
        .padding()
        .cookbookNavBarTitle("SynthOne Preset Loader")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
        .background(colorScheme == .dark ?
                     Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}
