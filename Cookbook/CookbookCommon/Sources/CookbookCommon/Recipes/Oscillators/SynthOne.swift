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

let strSnake3 = """
{"bank":"BankA","vco2Detuning":-3.469446951953614e-17,"attackDuration":0.005498750135302544,"filterDecay":0.0625,"subOscSquareToggled":0,"reverbFeedback":0.4653500020503998,"filterType":0,"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"releaseDuration":0.12000000189989805,"autoPanAmount":0,"pitchLFO":0,"pitchbendMaxSemitones":12,"delayInputResonance":0,"waveform2":0.2575107216835022,"compressorReverbWetRelease":0.15000000596046448,"modWheelRouting":0,"tempoSyncToArpRate":1,"lfo2Amplitude":0.016666000708937645,"compressorReverbInputAttack":0.0010000000474974513,"autoPanFrequency":0.2569444477558136,"glide":0,"arpInterval":12,"uid":"BCC30B44-EA27-4DE6-9CEC-D76786BE4774","compressorReverbInputThreshold":-8.5,"delayToggled":0,"compressorMasterRatio":20,"phaserRate":12,"noiseVolume":0.18607406318187714,"midiBendRange":2,"compressorMasterRelease":0.15000000596046448,"vco2Volume":0.800000011920929,"reverbHighPass":700,"frequencyA4":440,"lfoAmplitude":0,"resonanceLFO":0,"fmVolume":0,"detuneLFO":0,"subOsc24Toggled":1,"tremoloLFO":0,"fmAmount":0,"phaserFeedback":0,"sustainLevel":0,"filterSustain":1,"arpTotalSteps":8,"crushFreq":48000,"pitchbendMinSemitones":-12,"lfo2Waveform":0,"vco2Semitone":19,"category":4,"resonance":0.10000000149011612,"delayInputCutoffTrackingRatio":0.75,"reverbMix":0.23499999940395355,"filterEnvLFO":0,"widen":0,"position":74,"filterAttack":0.0005000000237487257,"decayDuration":0.12099999934434891,"vco1Semitone":0,"compressorReverbWetRatio":13,"compressorReverbInputMakeupGain":1.8799999952316284,"userText":"AudioKit Synth One preset. Nice lead dance pluck. Preset by Matthew Fecher","lfo2Rate":0.0963541716337204,"filterRelease":0.0949999988079071,"isHoldMode":0,"seqPatternNote":[0,0,12,12,0,-12,0,4,0,0,0,0,0,0,0,0],"transpose":0,"isMono":0,"cutoff":4600.3251953125,"noiseLFO":0,"isFavorite":true,"compressorMasterMakeupGain":2,"isUser":true,"delayTime":0.1621621549129486,"arpOctave":0,"compressorReverbInputRatio":13,"masterVolume":1.715000033378601,"vcoBalance":0.5,"octavePosition":1,"delayMix":0.17812499403953552,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"compressorReverbWetThreshold":-8,"seqNoteOn":[true,false,true,false,true,true,false,false,true,true,true,true,true,true,true,true],"decayLFO":0,"fmLFO":0,"delayFeedback":0.23274999856948853,"reverbMixLFO":0,"cutoffLFO":0,"compressorMasterThreshold":-9,"compressorReverbInputRelease":0.22499999403953552,"compressorReverbWetMakeupGain":1.8799999952316284,"filterADSRMix":1,"arpSeqTempoMultiplier":0.25,"lfoRate":0.0963541716337204,"compressorReverbWetAttack":0.0010000000474974513,"arpRate":185,"name":"Snake w Rev+Delay JFU 3","arpDirection":0,"reverbToggled":0,"oscBandlimitEnable":0,"oscMixLFO":0,"subVolume":0.4749999940395355,"isArpMode":0,"phaserMix":0,"lfoWaveform":0,"compressorMasterAttack":0.0010000000474974513,"waveform1":0.04908376932144165,"author":"","phaserNotchWidth":800,"arpIsSequencer":true,"adsrPitchTracking":0,"tuningName":"12 ET","isLegato":0,"vco1Volume":0.800000011920929,"bitcrushLFO":0}
"""

let strBrightOrgan3 = """
{"bitcrushLFO":0,"filterRelease":0.5051110982894897,"tuningName":"12 ET","seqPatternNote":[0,-12,12,5,4,12,5,4,0,0,0,0,0,0,0,0],"compressorReverbWetRelease":0.15000000596046448,"midiBendRange":2,"cutoff":22050,"subVolume":0.1224999949336052,"filterType":0,"modWheelRouting":0,"autoPanAmount":0.14499999582767487,"compressorMasterMakeupGain":2,"compressorMasterRatio":20,"filterADSRMix":0.08035492151975632,"tempoSyncToArpRate":1,"waveform1":0,"autoPanFrequency":0.5,"compressorReverbInputRatio":13,"arpSeqTempoMultiplier":0.25,"delayInputResonance":0,"decayDuration":0.35208356380462646,"crushFreq":48000,"reverbHighPass":114.8499984741211,"compressorReverbInputAttack":0.0010000000474974513,"compressorReverbWetAttack":0.0010000000474974513,"compressorMasterRelease":0.15000000596046448,"compressorReverbInputMakeupGain":1.8799999952316284,"reverbFeedback":0.8474999666213989,"vco2Semitone":24,"lfoRate":0.0625,"compressorReverbWetRatio":13,"seqNoteOn":[true,false,true,true,true,true,true,true,true,true,true,true,true,true,true,true],"compressorMasterAttack":0.0010000000474974513,"isMono":0,"detuneLFO":0,"isUser":true,"reverbMix":0.15500015020370483,"name":"Bright Organ EP 3","compressorReverbInputThreshold":-8.5,"compressorReverbInputRelease":0.22499999403953552,"delayMix":0.21937499940395355,"arpDirection":0,"compressorMasterThreshold":-9,"reverbToggled":0,"noiseVolume":0,"position":60,"filterDecay":0.25249993801116943,"isHoldMode":0,"isArpMode":0,"userText":"AudioKit Synth One preset. An organ built into a dark building?  Played by someone sinister... Preset by Fecher","fmVolume":0.7925000190734863,"transpose":0,"lfo2Amplitude":0.2574999928474426,"pitchbendMaxSemitones":12,"filterSustain":0.28070372343063354,"decayLFO":0,"frequencyA4":440,"category":2,"arpOctave":2,"attackDuration":0.005498750135302544,"delayToggled":0,"subOscSquareToggled":0,"vco2Detuning":-1.0399999618530273,"waveform2":0.16524748504161835,"adsrPitchTracking":0,"isLegato":0,"lfo2Waveform":0,"delayInputCutoffTrackingRatio":0.75,"vco2Volume":0.8600000143051147,"tremoloLFO":0,"phaserNotchWidth":800,"lfo2Rate":4,"filterAttack":0.0104975001886487,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"arpInterval":12,"reverbMixLFO":0,"cutoffLFO":0,"fmLFO":0,"resonanceLFO":0,"phaserFeedback":0,"filterEnvLFO":0,"lfoWaveform":0,"bank":"BankA","noiseLFO":0,"subOsc24Toggled":0,"sustainLevel":0.09662987291812897,"pitchbendMinSemitones":-12,"compressorReverbWetMakeupGain":1.8799999952316284,"vco1Volume":0.8450000286102295,"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"octavePosition":0,"uid":"028EE6D9-1EAE-4F66-A0BB-8FAC5EA9E90E","releaseDuration":0.6805700063705444,"isFavorite":true,"phaserMix":0,"arpIsSequencer":false,"delayFeedback":0.2214999943971634,"widen":0,"vcoBalance":0.32499998807907104,"masterVolume":0.19249999523162842,"author":"","arpTotalSteps":8,"vco1Semitone":12,"glide":0,"resonance":0.10000000149011612,"delayTime":0.0833333283662796,"compressorReverbWetThreshold":-8,"pitchLFO":0,"oscMixLFO":0,"fmAmount":0,"arpRate":120,"lfoAmplitude":0,"phaserRate":12,"oscBandlimitEnable":0}
"""

let strPluckYou3 = """
{"reverbToggled":1,"reverbHighPass":149.6999969482422,"compressorReverbInputMakeupGain":0.5,"phaserFeedback":0,"releaseDuration":0.05000000074505806,"tempoSyncToArpRate":1,"resonanceLFO":0,"lfoRate":1,"compressorMasterThreshold":0,"compressorReverbWetRelease":0,"arpRate":120,"name":"Pluck you 3 JFU","tuningName":"12 ET","compressorReverbWetRatio":1,"arpInterval":12,"oscBandlimitEnable":0,"filterEnvLFO":0,"userText":"AudioKit Synth One. \nPreset by Sound of Izrael","author":"","cutoffLFO":0,"adsrPitchTracking":0,"frequencyA4":440,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"delayMix":0.5,"seqPatternNote":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"subOsc24Toggled":0,"sustainLevel":0,"compressorMasterMakeupGain":0.5,"modWheelRouting":0,"compressorMasterRatio":1,"widen":0,"vco2Volume":0.75,"attackDuration":0.0005000000237487257,"filterADSRMix":0.44700002670288086,"vco1Semitone":0,"compressorReverbInputAttack":0,"isMono":0,"masterVolume":0.5,"phaserNotchWidth":800,"lfoAmplitude":0.3199999928474426,"compressorReverbInputRatio":1,"crushFreq":48000,"waveform2":0.3434579372406006,"transpose":0,"noiseVolume":0.015625,"category":6,"delayInputResonance":0,"compressorReverbWetAttack":0,"reverbFeedback":0.7300000190734863,"bitcrushLFO":0,"arpSeqTempoMultiplier":0.25,"isFavorite":true,"cutoff":2000,"delayFeedback":0.10000000149011612,"vcoBalance":0.5,"arpOctave":1,"isHoldMode":0,"arpDirection":0,"lfo2Waveform":0,"reverbMix":0.22750000655651093,"subVolume":0.03555557131767273,"vco1Volume":0.75,"lfo2Rate":3.000000238418579,"tremoloLFO":0,"compressorReverbInputThreshold":0,"isLegato":0,"fmAmount":9.975000381469727,"isUser":true,"pitchLFO":0,"decayLFO":0,"phaserMix":0,"compressorReverbWetMakeupGain":0.5,"bank":"Sound of Izrael","vco2Detuning":0,"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"vco2Semitone":12,"filterDecay":0.8735823035240173,"phaserRate":12,"fmLFO":0,"noiseLFO":0,"decayDuration":0.6385250091552734,"autoPanAmount":0,"resonance":0.10000000149011612,"oscMixLFO":0,"isArpMode":0,"uid":"848BA35B-57A0-4ECC-A4CE-1B9931D3CB5B","arpTotalSteps":8,"subOscSquareToggled":0,"delayToggled":0,"reverbMixLFO":0,"delayTime":0.3333333134651184,"pitchbendMaxSemitones":0,"position":50,"glide":0,"midiBendRange":2,"pitchbendMinSemitones":0,"lfo2Amplitude":0.4925000071525574,"seqNoteOn":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],"filterSustain":1,"detuneLFO":0,"filterRelease":0.14499999582767487,"octavePosition":0,"compressorMasterAttack":0,"autoPanFrequency":0.25,"filterAttack":0.0005000000237487257,"lfoWaveform":1,"fmVolume":0.4000000059604645,"compressorMasterRelease":0,"compressorReverbInputRelease":0,"delayInputCutoffTrackingRatio":0.75,"filterType":0,"compressorReverbWetThreshold":0,"arpIsSequencer":false,"waveform1":0}
"""

let strTotallyTubular3 = """
{"noiseLFO":0,"vco2Detuning":0.9399999976158142,"filterADSRMix":0.8928000330924988,"compressorMasterMakeupGain":2,"cutoffLFO":0,"compressorReverbInputThreshold":-8.5,"detuneLFO":0,"uid":"F3A8BE55-B17A-404F-AF65-336B5F7BDA15","oscBandlimitEnable":0,"octavePosition":0,"lfo2Waveform":0,"lfo2Amplitude":0.8366659879684448,"fmAmount":0.10666580498218536,"cutoff":8419.37890625,"crushFreq":48000,"arpTotalSteps":16,"compressorReverbWetRelease":0.15000000596046448,"lfoAmplitude":0.4962500035762787,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"arpInterval":3,"seqOctBoost":[false,false,false,false,false,false,true,false,false,false,false,true,false,false,true,true],"compressorReverbWetRatio":13,"compressorReverbWetThreshold":-8,"arpSeqTempoMultiplier":0.25,"delayMix":0.171875,"sustainLevel":0.014222259633243084,"tuningName":"12 ET","compressorReverbWetAttack":0.0010000000474974513,"vco1Semitone":0,"filterRelease":0.15649987757205963,"compressorReverbInputRelease":0.22499999403953552,"category":1,"midiBendRange":2,"filterAttack":0.0005000000237487257,"vco1Volume":0.800000011920929,"resonance":0.10000000149011612,"vco2Semitone":12,"oscMixLFO":0,"reverbHighPass":442.3374938964844,"filterDecay":0.39729341864585876,"filterEnvLFO":0,"delayTime":0.3030302822589874,"seqPatternNote":[0,-5,-7,-12,-7,0,7,0,-12,0,-2,-7,-12,0,12,3],"compressorMasterRelease":0.15000000596046448,"isHoldMode":0,"compressorReverbInputRatio":13,"subOscSquareToggled":0,"adsrPitchTracking":0,"isFavorite":true,"filterType":0,"autoPanFrequency":0.20625001192092896,"subOsc24Toggled":0,"reverbMix":0.11000000685453415,"attackDuration":0.0005000000237487257,"noiseVolume":0,"pitchbendMaxSemitones":12,"reverbFeedback":0.6196499466896057,"pitchLFO":0,"resonanceLFO":0,"masterVolume":0.6550000309944153,"glide":0,"phaserMix":0,"delayInputCutoffTrackingRatio":0.75,"tempoSyncToArpRate":1,"waveform2":0.28738316893577576,"compressorReverbInputMakeupGain":1.8799999952316284,"phaserRate":12,"lfoWaveform":0,"lfo2Rate":0.13750001788139343,"arpOctave":1,"isArpMode":0,"userText":"AudioKit Synth One preset. Twist the knobs to indulge your analog desires. \nPreset by by Matthew Feccher","widen":0,"seqNoteOn":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],"modWheelRouting":0,"arpIsSequencer":true,"frequencyA4":440,"releaseDuration":0.39031898975372314,"bitcrushLFO":0,"delayInputResonance":0,"delayFeedback":0.10000000149011612,"name":"Totally Tubular JFU 3","author":"","reverbMixLFO":0,"isLegato":0,"arpDirection":0,"filterSustain":0,"fmVolume":0.052148208022117615,"fmLFO":0,"phaserNotchWidth":800,"arpRate":99,"isMono":0,"compressorMasterRatio":20,"tremoloLFO":0,"isUser":true,"compressorMasterAttack":0.0010000000474974513,"phaserFeedback":0,"vcoBalance":0,"bank":"BankA","compressorReverbWetMakeupGain":1.8799999952316284,"lfoRate":0.4125000238418579,"autoPanAmount":0.014222183264791965,"transpose":0,"compressorMasterThreshold":-9,"compressorReverbInputAttack":0.0010000000474974513,"position":48,"delayToggled":0,"decayDuration":0.5167812705039978,"pitchbendMinSemitones":-12,"waveform1":0.25,"subVolume":0.40087035298347473,"decayLFO":0,"vco2Volume":0.800000011920929,"reverbToggled":0}
""";

//"waveform1": 0.25,
//"waveform2": 0.28738316893577576,
//"fmAmount": 0.10666580498218536,
//"fmVolume": 0.052148208022117615,

struct Synth1Preset: Decodable {
//    let adsrPitchTracking: Float
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
//    let cutoffLFO: Float
    let decayDuration: Float // seconds?
//    "decayLFO": 0,
//    "delayFeedback": 0.10000000149011612,
//    "delayInputCutoffTrackingRatio": 0.75,
//    "delayInputResonance": 0,
//    "delayMix": 0.171875,
//    "delayTime": 0.3030302822589874,
//    "delayToggled": 0,
//    "detuneLFO": 1,
//    let filterADSRMix: Float
//    let filterAttack: Float
//    let filterDecay: Float
//    "filterEnvLFO": 0,
//    let filterRelease: Float
//    let filterSustain: Float
//    let filterType: Int // ?
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
//    let noiseVolume: Float
//    "octavePosition": 0,
//    let oscBandlimitEnable: Int // 0 or 1, really a boolean
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

// eliminate annoying, unwanted auto glissando / portamento effect w/ NodeParameter.ramp(to: value, duration: 0)
func paramFinder(_ node: Node, ident: String) -> NodeParameter? {
    for parameter in node.parameters {
        if parameter.def.identifier == ident {
            return parameter
        }
    }
    return nil
}

class S1GeneratorBank {
    //public var engine = AudioEngine()
    var vco1 = MorphingOscillator()
    var vco2 = MorphingOscillator()
    var fmOsc = FMOscillator()
    var subOsc: Oscillator
    var ampEnv: AmplitudeEnvelope

    var vco1Mixer: Mixer
    var vco2Mixer: Mixer
    var fmOscMixer: Mixer
    var subMixer: Mixer
    var bankMixer: Mixer
    var vcoBalancer: DryWetMixer
    var adsrMixer: Mixer
    
    var moogFilter: MoogLadder
    
    var vco1SemiTonesOffset: Int8
    var vco2SemiTonesOffset: Int8
    var subIs24: Bool

    func noteOn(pitch: Pitch, point _: CGPoint) {
        //isPlaying = true
        let f1 = AUValue(pitch.midiNoteNumber + vco1SemiTonesOffset).midiNoteToFrequency()
        if let p = paramFinder(vco1, ident: "frequency") {
            p.ramp(to: f1, duration: 0)
        }
        //vco1.frequency = f
        let f2 = AUValue(pitch.midiNoteNumber + vco2SemiTonesOffset).midiNoteToFrequency()
        if let p = paramFinder(vco2, ident: "frequency") {
            p.ramp(to: f2, duration: 0)
        }
        let fmF = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
        if let p = paramFinder(fmOsc, ident: "baseFrequency") {
            p.ramp(to: fmF, duration: 0)
        }
        
        var subOscF: AUValue = 0
        if(subIs24 && pitch.midiNoteNumber > 24) {
            subOscF = AUValue(pitch.midiNoteNumber - 24).midiNoteToFrequency()
        }
        else if(pitch.midiNoteNumber > 12) {
            subOscF = AUValue(pitch.midiNoteNumber - 12).midiNoteToFrequency()
        }
        if let p = paramFinder(subOsc, ident: "frequency") {
            p.ramp(to: subOscF, duration: 0)
        }
        
        // TODO use point.x or point.y to set ADSR envelope height / velocity / volume
        //vco1.amplitude = // TODO point.whatever
        //vco2.amplitude = // TODO point.whatever
        ampEnv.openGate()
    }

    func noteOff(pitch _: Pitch) {
        //isPlaying = false
        ampEnv.closeGate()
    }
    
    public let output: Node

    init(_ synth1Preset: Synth1Preset) {
        vco1.amplitude = synth1Preset.vco1Volume
        vco1.index = synth1Preset.waveform1 * 3.0
        vco1SemiTonesOffset = Int8(synth1Preset.vco1Semitone)
        vco1Mixer = Mixer(vco1)
        vco1Mixer.volume = synth1Preset.vco1Volume
        
        vco2.amplitude = synth1Preset.vco2Volume
        vco2.index = synth1Preset.waveform2 * 3.0
        vco2.detuningOffset = synth1Preset.vco2Detuning
        vco2SemiTonesOffset = Int8(synth1Preset.vco2Semitone)
        vco2Mixer = Mixer(vco2)
        vco2Mixer.volume = synth1Preset.vco2Volume
        
        vcoBalancer = DryWetMixer(vco1Mixer, vco2Mixer, balance: AUValue(synth1Preset.vcoBalance))
        
        fmOscMixer = Mixer(fmOsc)
        fmOsc.modulationIndex = synth1Preset.fmAmount
        //fmOsc.modulatingMultiplier // not used, apparently
        fmOscMixer.volume = synth1Preset.fmVolume
        
        subIs24 = synth1Preset.subOscIs24
        // note this would not allow changing later, say, at runtime. You have to initialize a totally new
        // S1GeneratorBank to get this to change
        // OR: TODO: subBalancer = DryWetMixer(subOsc1, subOsc2) // you get the idea
        subOsc = Oscillator(waveform:
                                synth1Preset.subOscIsSquare ? Table(.square) : Table(.sine))
        subMixer = Mixer(subOsc)
        subMixer.volume = synth1Preset.subVolume

        bankMixer = Mixer(vcoBalancer, fmOscMixer, subMixer)
        
        moogFilter = MoogLadder(bankMixer, cutoffFrequency: synth1Preset.cutoff, resonance: synth1Preset.resonance)
        
        ampEnv = AmplitudeEnvelope(moogFilter)
        ampEnv.attackDuration = synth1Preset.attackDuration
        ampEnv.decayDuration = synth1Preset.decayDuration
        ampEnv.sustainLevel = synth1Preset.sustainLevel
        ampEnv.releaseDuration = synth1Preset.releaseDuration
        adsrMixer = Mixer(ampEnv)
        
        adsrMixer.volume = 0.2 // TODO deal with the fact this is so loud but we don't want to blow out our ears testing
        //let engine = AudioEngine()
        output = adsrMixer
        
        vco1.start()
        vco2.start()
        fmOsc.start()
        subOsc.start()
        ampEnv.start()
    }
}
// easy!
// 0. Noise too


func JSONToPreset(_ str: String) -> Synth1Preset {
    let jsonData = str.data(using: .utf8)!
    let synth1Preset: Synth1Preset = try! JSONDecoder().decode(Synth1Preset.self, from: jsonData)
    print("synth1Preset: \(synth1Preset)")
    return synth1Preset
}


// For JFU Pianos project:
// 1. Next add polyphony (16-voices?)
// 2. Wire up to hardware keyboard (see other example, but don't load big slow 40-second piano)
// ---- wow that is already pretty cool, if a bit ear-crunching (needs:)
// 3. ADSR envelope for filter cutoff, which will requite C/C++ DSP, according to
//    https://stackoverflow.com/questions/48722796/how-to-synchronize-osc-and-filter-envelope-by-note-gate-in-audiokit
//    https://github.com/AudioKit/AudioKitSynthOne/blob/master/AudioKitSynthOne/DSP/Kernel/S1DSPKernel%2Bprocess.mm
// would be nice:
// 4. LFO too?
// 5. Phaser too?
// 6. Pitch track?
//
// list of things not supported (piano / pluck focused):
// - portamento e.g. mono v. poly (only poly)
// - arp / seq
// - tuning tables
// - bitcrush
// - auto-pan or widen
// - reverb (will be in Pianos app, not S1Preset player)
// - delay  (will be in Pianos app, not S1Preset player)

// polyphony implmented here
class SynthOneConductor: ObservableObject, HasAudioEngine {
    var engine = AudioEngine()
    var osc: S1GeneratorBank

    func noteOn(pitch: Pitch, point: CGPoint) {
//        isPlaying = true
        osc.noteOn(pitch: pitch, point: point)
    }

    func noteOff(pitch: Pitch) {
        osc.noteOff(pitch: pitch)
    }

//    @Published var isPlaying: Bool = false {
//        didSet { isPlaying ? osc.start() : osc.stop() }
//    }
    
    var polyMixer: Mixer

    init(_ str: String) {
        osc = S1GeneratorBank(JSONToPreset(str))
        //engine = osc.engine
        polyMixer = Mixer([osc.output])
        engine.output = polyMixer
    }
}

struct SynthOneView: View {
    @StateObject var conductor = SynthOneConductor(strSnake3)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
            CookbookKeyboard(noteOn: conductor.noteOn,
                             noteOff: conductor.noteOff)
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
