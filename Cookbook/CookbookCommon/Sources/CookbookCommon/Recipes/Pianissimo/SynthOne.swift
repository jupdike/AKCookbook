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
import SporthAudioKit
import STKAudioKit

//"waveform1": 0.25,
//"waveform2": 0.28738316893577576,
//"fmAmount": 0.10666580498218536,
//"fmVolume": 0.052148208022117615,

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
    let filterADSRMix: Float
    let filterAttack: Float
    let filterDecay: Float
//    "filterEnvLFO": 0,
    let filterRelease: Float
    let filterSustain: Float
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
    let noiseVolume: Float
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

    // computed properties for convenience
    var subOscIs24: Bool { subOsc24Toggled > 0 }
    var subOscIsSquare: Bool { subOscSquareToggled > 0 }
    
    // according to OperationDSP.mm
    // OperationTrigger is 14, so
    // 14 p    is left channel
    // 15 p    is right channel

    // for why we need to use Sporth instead of just using Node() a bunch:
    //    https://stackoverflow.com/questions/48722796/how-to-synchronize-osc-and-filter-envelope-by-note-gate-in-audiokit
    //    https://github.com/AudioKit/AudioKitSynthOne/blob/master/AudioKitSynthOne/DSP/Kernel/S1DSPKernel%2Bprocess.mm

    var moogFilterEnvAmpEnvSporth: String {
        // TODO also DryWetMix using s1preset.filterADSRMix (should be done inside, after moogladder, before adsr)
        // (0 p) is a gate set by noteOn/noteOff
        let filterAdsrParams = "\(filterAttack)   \(filterDecay)   \(filterSustain) \(filterRelease)"
        let ampAdsrParams =    "\(attackDuration) \(decayDuration) \(sustainLevel)  \(releaseDuration)"
        let ret = """
_cutoff var
_gate var
_velocity var
_leftin var

\(cutoff) _cutoff set
(0 p) _gate set
(1 p) _velocity set
(14 p) _leftin set

_leftin get
(
  \(filterADSRMix) 1.0 min
  _cutoff get
  (
    _cutoff get
    (_gate get) \(filterAdsrParams) adsr
    *
  )
  scale
  
)
\(resonance) moogladder

((_gate get) \(ampAdsrParams) adsr) *
(_velocity get) *

dup
"""
        // N.B. \(filterADSRMix) 1.0 min   is left like this because later we will do some LFO computation and then clamp to 1.0 max, and UI lets users set mix to 120%, otherwise we get pops and cracks (overflow) if we don't clamp this
        print(ret)
        return ret
    }
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

class S1GeneratorBank: Noter {
    var vco1 = MorphingOscillator()
    var vco2 = MorphingOscillator()
    var fmOsc = FMOscillator()
    var subOsc: Oscillator
    var noise: WhiteNoise
    
    // moog filter into a filter envelope that controls cutoff
    // could add LFO-controlled cutoff to filter env for even more flexibility
    // also applies velocity and adsr amp env
    var filter: OperationEffect

    var vco1Mixer: Mixer
    var vco2Mixer: Mixer
    var fmOscMixer: Mixer
    var subMixer: Mixer
    var bankMixer: Mixer
    var vcoBalancer: DryWetMixer
    var filterMixer: Mixer
        
    var vco1SemiTonesOffset: Int8
    var vco2SemiTonesOffset: Int8
    var subIs24: Bool
    var masterVolume: Float
    var adsrPitchTracking: Float
    
    static func getPitchTrackRatio(semis: Int, adsrPitchTracking: Float) -> Float {
        // adsr pitch tracking
        let vco1NoteNumber = Float(semis)
        let vco1Hz: Float = exp2(vco1NoteNumber / 12.0)
        let ptch: Float = log2(vco1Hz > 0 ? vco1Hz : 261.0)
        let ymin: Float = 6.0
        let ymax: Float = 11.0
        let kt0: Float = (ptch - ymin) / (ymax - ymin)
        var kt1: Float = Float(1.0 - clamp(Double(kt0), 0.0, 1.0))
        kt1 *= kt1
        let ktfloor: Float = 1.0 - adsrPitchTracking
        let kt2: Float = ((1.0 - ktfloor) * kt1) + ktfloor
        return kt2
    }

    func noteOn(pitch: Pitch, point: CGPoint) {
        let velocity: Float = Float(point.y)
        var semis: Int = Int(pitch.midiNoteNumber)
        semis += Int(vco1SemiTonesOffset)
        let pitchTrackRatio = S1GeneratorBank.getPitchTrackRatio(semis: semis, adsrPitchTracking: adsrPitchTracking)
        
        let f1 = AUValue(semis).midiNoteToFrequency()
        if let p = paramFinder(vco1, ident: "frequency") {
            p.ramp(to: f1, duration: 0)
        }
        let f2 = AUValue(Int(pitch.midiNoteNumber) + Int(vco2SemiTonesOffset)).midiNoteToFrequency()
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

        // this is confusing. In Swift the parameters are numbered from 1 to 14
        // but in Sporth they go from 0 to 13 with (14 p) and (15 p) corresponding to the input left and right channel samples
        // so parameter1 is (0 p) in Sporth...

        // MIDI-controlled gate for filter envelope
        if let p = paramFinder(filter, ident: "parameter1") {
            print("S1Preset MIDI Gate. Old (0 p) or parameter1: \(p.value) ramp to 1 instantaneously")
            p.ramp(to: 1, duration: 0)
        }
        
        // set MIDI-controlled velocity instantaneously for parameter2 / (1 p)
        if let p = paramFinder(filter, ident: "parameter2") {
            p.ramp(to: velocity * pitchTrackRatio, duration: 0)
        }
    }

    func noteOff(pitch _: Pitch) {
        // MIDI-controlled gate for filter envelope
        if let p = paramFinder(filter, ident: "parameter1") {
            print("S1Preset MIDI Gate. Old (0 p) or parameter1: \(p.value) ramp to 0 instantaneously")
            p.ramp(to: 0, duration: 0)
        }
    }

    public let output: Node
    
    init(_ synth1Preset: Synth1Preset) {
        adsrPitchTracking = synth1Preset.adsrPitchTracking
        
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
        // see https://github.com/AudioKit/AudioKitSynthOne/blob/6466a3715c96b7ecf1dd255a218cbd571408a314/AudioKitSynthOne/DSP/Note%20State/S1NoteState.mm#L382
        subMixer = Mixer(subOsc)
        subMixer.volume = synth1Preset.subVolume * (synth1Preset.subOscIsSquare ? 1.0 : 3.0) // make sine louder, per AKS1 source code
        
        noise = WhiteNoise()
        noise.amplitude = synth1Preset.noiseVolume
        
        bankMixer = Mixer(vcoBalancer, fmOscMixer, subMixer, noise)
        
        filter = OperationEffect(bankMixer, sporth: synth1Preset.moogFilterEnvAmpEnvSporth)
        
        masterVolume = synth1Preset.masterVolume
        filterMixer = Mixer(filter)
        filterMixer.volume = masterVolume
        
        output = filterMixer
    }
    
    func start() {
        noise.start()
        vco1.start()
        vco2.start()
        fmOsc.start()
        subOsc.start()
        filter.start()
    }
    
    func stop() {
        noise.stop()
        vco1.stop()
        vco2.stop()
        fmOsc.stop()
        subOsc.stop()
        filter.stop()
    }

    static func IndentitySporthOp(_ node : Node) -> OperationEffect {
        let sporthStr = """
14 p
15 p
"""
        // sport processing code goes here, to deal with those two channels on the stack
        // or just use 14 p above if mono (left channel only) then call dup later
        //
        // then that sporth code leaves a single mono and calls (dup)
        // or that code leaves two values on the stack
        return OperationEffect(node, sporth: sporthStr)
    }

}


func JSONToPreset(_ str: String) -> Synth1Preset {
    let jsonData = str.data(using: .utf8)!
    print("---------\nTRYING TO PARSE: \(str)\n----------")
    let synth1Preset: Synth1Preset = try! JSONDecoder().decode(Synth1Preset.self, from: jsonData)
    print("synth1Preset: \(synth1Preset)")
    return synth1Preset
}

// polyphony implmented here
class MonoToPolyConductor: ObservableObject, Noter {
    let monoGens: [Noter]
    var nextGen = 0
    // maps midinote to index
    var keyDownTracker: [Int: Int] = [:]

    func noteOn(pitch: Pitch, point: CGPoint) {
        let p = Int(pitch.midiNoteNumber)
        var index = -1
        // deal with case where there are MAX_POLY keys down already and one needs to be sent noteOfff, remove oldest note
        if keyDownTracker.count >= MAX_POLY - 1 {
            print("*** TOO MANY KEYS BEING HELD DOWN")
            let nextGenMinusOne = (nextGen - 1 + MAX_POLY) % MAX_POLY
            if keyDownTracker.values.contains(nextGenMinusOne) {
                print("FORCIBLY REMOVED A KEY")
                monoGens[nextGenMinusOne].noteOff(pitch: pitch)
                var keyForValue = -1
                for (k, v) in keyDownTracker {
                    if v == nextGenMinusOne {
                        keyForValue = k
                        break
                    }
                }
                if keyForValue > -1 {
                    keyDownTracker.removeValue(forKey: keyForValue)
                }
                nextGen = (nextGen + 1) % MAX_POLY // never fill up all of them, so we always have an open slot
            }
        }
        // retriggering a key that is already down (without a note off first) can happen when sustain pedal is down. allow gate to end and release to occur
        if keyDownTracker.keys.contains(p) {
            if let slatedForRemoval = keyDownTracker[p] {
                print("*** retriggering a key that was not manually released (sustain pedal down?)")
                monoGens[slatedForRemoval].noteOff(pitch: pitch)
                keyDownTracker.removeValue(forKey: slatedForRemoval)
            }
        } else {
            for (key, value) in keyDownTracker {
                if key == p {
                    index = value
                }
            }
        }
        if index == -1 {
            index = nextGen
            nextGen = (nextGen + 1) % MAX_POLY
            var bail = 0
            while keyDownTracker.values.contains(nextGen) {
                nextGen = (nextGen + 1) % MAX_POLY
                // don't get stuck in infinite loop
                bail += 1
                if bail == MAX_POLY {
                    break
                }
            }
        }
        monoGens[index].noteOn(pitch: pitch, point: point)
        keyDownTracker[p] = index
        print("*** keys down: \(keyDownTracker.count)")
    }

    func noteOff(pitch: Pitch) {
        let p = Int(pitch.midiNoteNumber)
        if let index = keyDownTracker[p] {
            monoGens[index].noteOff(pitch: pitch)
            keyDownTracker.removeValue(forKey: p)
        }
    }
    
    func stop() {
        for gen in monoGens {
            gen.stop()
        }
    }
    
    func start() {
        for gen in monoGens {
            gen.start()
        }
    }
    
    var output: Node

//    @Published var isPlaying: Bool = false {
//        didSet { isPlaying ? osc.start() : osc.stop() }
//    }
    
    var polyMixer: Mixer
    
    let MAX_POLY = 16

    init(_ noterMaker: () -> Noter) {
        monoGens = (0 ..< MAX_POLY).map({ _ in noterMaker() })
        polyMixer = Mixer(monoGens.map({ $0.output }))
        output = polyMixer
    }
}

class MIDIPlayable: ObservableObject {
    //let engine = AudioEngine()
    let noter: Noter
    let midiConductor = MIDIMonitorConductor2()
    
    // for tapping or clicking, not MIDI HW KB which needs to consult sustain pedal state too
    func noteOn(pitch: Pitch, point: CGPoint) {
        noter.noteOn(pitch: pitch, point: point)
    }

    // for tapping or clicking, not MIDI HW KB which needs to consult sustain pedal state too
    func noteOff(pitch: Pitch) {
        noter.noteOff(pitch: pitch)
    }
    
    func start() {
        //do { try engine.start() } catch let err { Log(err) }
        midiConductor.start()
    }
    
    func stop() {
        //engine.stop()
        midiConductor.stop()
    }
    
    var output: Node {
        noter.output
    }
    
    init(_ noter: Noter) {
        self.noter = noter
        self.midiConductor.instrumentConductor = noter
        //engine.output = noter.output
    }
}

func getOneFile(_ url: URL) -> String {
    var ret = ""
    do {
        ret = try String(contentsOf: url)
    }
    catch let error {
        // Error handling
        Log("ERROR: \(error)\nCould not find file \(url)")
    }
    return ret
}

func getS1Presets() -> [String] {
    var bigStrs: [String] = []
    if var urls = Bundle.main.urls(forResourcesWithExtension: "synth1", subdirectory: "Sounds/S1Presets") {
        urls.sort { $0.lastPathComponent < $1.lastPathComponent }
        for url in urls {
            // for files that have a problem
            if url.lastPathComponent.starts(with: "_") {
                continue
            }
            let contents = getOneFile(url)
            if contents != "" {
                bigStrs.append(contents)
            }
        }
    }
    //return bigStrs.map({ [JSONToPreset($0).name, $0] })
    return bigStrs
}

let allStrs = getS1Presets()
var strPairs: [[String]] {
    allStrs.map({ [JSONToPreset($0).name, $0] })
}

protocol HandlesPresetPick {
    func presetPicked(name: String, rhs: String)
    func stop()
    func start()
    func noteOn(pitch: Pitch, point: CGPoint)
    func noteOff(pitch: Pitch)
}

enum STKAudioBased {
    case TubularBells, RhosePianoKey, MandolinString
}

enum PhysicalType {
    case stkBase(STKAudioBased)
    case pluckedString
    
    static func fromString(_ str: String) -> PhysicalType? {
        switch str {
        case "STKAudioKit.RhodesPianoKey":
            return .stkBase(.RhosePianoKey)
        case "STKAudioKit.TubularBells":
            return .stkBase(.TubularBells)
        case "STKAudioKit.MandolinString":
            return .stkBase(.MandolinString)
        case "STKAudioKit.PluckedString":
            return .pluckedString
        default:
            return nil
        }
    }
}

// all of these need full MIDI HW KB playability as well as real polyphony
class PhysicalBuiltinNoter: Noter {
    var plucked: PluckedString?
    var baser: STKBase?
    var output: Node
    var whichOne: PhysicalType
    
    let defaultRelease: Float = 0.2
    
    var ampEnv: AmplitudeEnvelope
    
    init(_ one: PhysicalType) {
        var node: Node
        whichOne = one
        switch one {
        case .pluckedString:
            plucked = PluckedString()
            plucked?.start()
            node = plucked!
        case .stkBase(let ok):
            switch ok {
            case .MandolinString:
                baser = MandolinString()
            case .RhosePianoKey:
                baser = RhodesPianoKey()
            case .TubularBells:
                baser = TubularBells()
            }
            baser?.start()
            node = baser!
        }
        ampEnv = AmplitudeEnvelope(node)
        ampEnv.attackDuration = 0
        ampEnv.decayDuration = 0
        ampEnv.sustainLevel = 1
        ampEnv.releaseDuration = defaultRelease
        output = ampEnv
    }
    
    func start() {
        ampEnv.start()
        plucked?.start()
        baser?.start()
    }
    
    func stop() {
        ampEnv.stop()
        plucked?.stop()
        baser?.stop()
    }
    
    func noteOn(pitch: Pitch, point: CGPoint) {
        switch(whichOne) {
        case .pluckedString:
            plucked?.frequency = MIDINoteNumber(pitch.midiNoteNumber).midiNoteToFrequency()
            plucked?.amplitude = AUValue(point.y)
            plucked?.trigger()
        case .stkBase(_):
            baser?.trigger(note: MIDINoteNumber(pitch.midiNoteNumber), velocity: MIDIVelocity(127.0 * point.y))
        }
        ampEnv.openGate()
    }

    func noteOff(pitch: Pitch) {
        ampEnv.closeGate()
    }
}

enum PianoConductorType {
    case s1Preset, grandPiano, cp80, wep200, pianet, stkAudio
}

class PresetPickHandler: HandlesPresetPick, ObservableObject {
    var lastName = ""
    var lastType: PianoConductorType = .s1Preset
    var s1player: Noter
    var grandPiano: InstrumentSFZConductor?
    var cp80: InstrumentSFZConductor?
    var wep200: InstrumentSFZConductor?
    var pianet: InstrumentSFZConductor?
    var physical: Noter
    
    var midiPlayable: MIDIPlayable?
    
    let engine = AudioEngine()
    
    init() {
        let s1preset = JSONToPreset(strPairs[INITIAL_PRESET_INDEX][1])
        s1player = MonoToPolyConductor({ S1GeneratorBank(s1preset) as any Noter })
        midiPlayable = MIDIPlayable(s1player)
        s1player.start()
        midiPlayable?.start()
        engine.output = midiPlayable?.output
        do { try engine.start() } catch let err { Log(err) }
        physical = MonoToPolyConductor({ PhysicalBuiltinNoter(.pluckedString) as any Noter })
    }

    func presetPicked(name: String, rhs: String) {
        if let gp = grandPiano {
            gp.stop()
        }
        s1player.stop()

        lastName = name
        // once piano is loaded, we don't want to unload it, because it takes so long to load
        if rhs.contains("SalGrandPiano") {
            lastType = .grandPiano
            if grandPiano == nil {
                grandPiano = InstrumentSFZConductor(rhs)
            }
            grandPiano?.start()
            grandPiano?.instrument.releaseDuration = 0.2
        }
        else if rhs.contains("CP80") {
            lastType = .cp80
            if cp80 == nil {
                cp80 = InstrumentSFZConductor(rhs)
            }
            cp80?.start()
            cp80?.instrument.attackDuration = 0.0
            cp80?.instrument.decayDuration = 2.0 // to prevent pop when end of sample reached
            cp80?.instrument.sustainLevel = 0.15 // decay to silence to avoid hearing pop
            cp80?.instrument.releaseDuration = 0.2
        }
        else if rhs.contains("WEP200") {
            lastType = .wep200
            if wep200 == nil {
                wep200 = InstrumentSFZConductor(rhs)
            }
            wep200?.start()
            wep200?.instrument.attackDuration = 0.0
            wep200?.instrument.decayDuration = 1.25 // to prevent pop when end of sample reached
            wep200?.instrument.sustainLevel = 0.05 // decay to silence to avoid hearing pop
            wep200?.instrument.releaseDuration = 0.1 // TODO tweak this?
        }
        else if rhs.contains("PianetT") {
            lastType = .pianet
            if pianet == nil {
                pianet = InstrumentSFZConductor(rhs)
            }
            pianet?.start()
            pianet?.instrument.attackDuration = 0.0
            pianet?.instrument.decayDuration = 2.0 // to prevent pop when end of sample reached
            pianet?.instrument.sustainLevel = 0.15 // decay to silence to avoid hearing pop
            pianet?.instrument.releaseDuration = 0.2 // TODO tweak this?
        }
        else if rhs.contains("STKAudioKit.") {
            if let which = PhysicalType.fromString(rhs) {
                engine.stop()
                physical.stop()
                physical = MonoToPolyConductor({ PhysicalBuiltinNoter(which) as any Noter })
                midiPlayable = MIDIPlayable(physical)
                midiPlayable?.start()
                physical.start()
                engine.output = physical.output
                do { try engine.start() } catch let err { Log(err) }
                lastType = .stkAudio
            }
        }
        else { // rhs is an S1Preset as JSON
            engine.stop()
            lastType = PianoConductorType.s1Preset
            let s1preset = JSONToPreset(rhs)
            s1player = MonoToPolyConductor({ S1GeneratorBank(s1preset) as any Noter })
            midiPlayable = MIDIPlayable(s1player)
            midiPlayable?.start()
            s1player.start()
            engine.output = s1player.output
            do { try engine.start() } catch let err { Log(err) }
            lastType = .s1Preset
        }
    }

    // for tapping or clicking, not MIDI HW KB which needs to consult sustain pedal state too
    func noteOn(pitch: Pitch, point: CGPoint) {
        switch(lastType) {
        case .grandPiano:
            grandPiano?.noteOn(pitch: pitch, point: point)
        case .cp80:
            cp80?.noteOn(pitch: pitch, point: point)
        case .wep200:
            wep200?.noteOn(pitch: pitch, point: point)
        case .pianet:
            pianet?.noteOn(pitch: pitch, point: point)
        case .s1Preset:
            s1player.noteOn(pitch: pitch, point: point)
        case .stkAudio:
            physical.noteOn(pitch: pitch, point: point)
        }
    }

    // for tapping or clicking, not MIDI HW KB which needs to consult sustain pedal state too
    func noteOff(pitch: Pitch) {
        switch(lastType) {
        case .s1Preset:
            s1player.noteOff(pitch: pitch)
        case .grandPiano:
            grandPiano?.noteOff(pitch: pitch)
        case .cp80:
            cp80?.noteOff(pitch: pitch)
        case .wep200:
            wep200?.noteOff(pitch: pitch)
        case .pianet:
            pianet?.noteOff(pitch: pitch)
        case .stkAudio:
            physical.noteOff(pitch: pitch)
        }
    }
    
    func start() {
        s1player.start()
    }
    
    func stop() {
        s1player.stop()
        grandPiano?.stop()
        pianet?.stop()
        cp80?.stop()
        wep200?.stop()
        physical.stop()
    }
}

let morePairs: [[String]] = [
    ["Y C5 Grand Piano", "Sounds/SalGrandPiano/GrandPianoV1"], // Salamander Grand Piano SFZ V2 rebuilt as V1
    ["Y CP-80 Electric Grand Piano", "Sounds/CP80/CP80"], // Greg Sullivan E-Pianos SFZ V2, ditto
    ["H PT Electro-mech Pianet", "Sounds/PianetT/PianetT"], // Greg Sullivan E-Pianos SFZ V2, etc.
    ["W EP200 Electric Piano", "Sounds/WEP200/WEP200"], // Greg Sullivan E-Pianos SFZ V2
    ["FR Mk 1 Vintage Electric Piano", "STKAudioKit.RhodesPianoKey"], // STKAudioKit, sampled
    ["Tubular Bells", "STKAudioKit.TubularBells"], // STKAudioKit
    ["Mandolin String", "STKAudioKit.MandolinString"], // STKAudioKit
    ["Plucked String", "STKAudioKit.PluckedString"], // STKAudioKit
    //    ["Sitar String", ""], // STKAudioKit // some day? once I can rebuild STKAudioKit from source and add Sitar myself
]

let combinedPairs = strPairs + morePairs

let INITIAL_PRESET_INDEX = 7

struct PianissimoView: View {
    @StateObject var conductor: PresetPickHandler = PresetPickHandler()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        PresetPicker(handlesPicked: conductor, sources: combinedPairs, pickedName: strPairs[INITIAL_PRESET_INDEX][0])
        CookbookKeyboard(noteOn: conductor.noteOn, noteOff: conductor.noteOff, octaveOffset: 0)
        .padding()
        .cookbookNavBarTitle("Pianissimo Preset Picker")
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
