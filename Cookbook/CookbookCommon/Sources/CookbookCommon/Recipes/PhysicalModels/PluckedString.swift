import AudioKit
import STKAudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//public class Sitar: Node, MIDITriggerable {
//    /// Connected nodes
//    public var connections: [Node] { [] }
//
//    /// Underlying AVAudioNode
//    public var avAudioNode: AVAudioNode
//
//    /// Initialize the STK Clarinet model
//    public init(/*_ code: String*/) {
//        avAudioNode = instantiate(instrument: "sitr")
//    }
//}


class PluckedStringConductor: ObservableObject {
    let engine = AudioEngine()
    let inst1 = PluckedString()
    let inst2 = MandolinString()
    let inst3 = TubularBells()
    let inst4 = RhodesPianoKey()
    var reverb: Reverb
    var playRate = 3.0
    var loop: CallbackLoop!

    @Published var isRunning = false {
        didSet {
            isRunning ? loop.start() : loop.stop()
        }
    }

    init() {
        let mixer = DryWetMixer(inst1, inst2) //, inst3, inst4)
        let delay = Delay(mixer)
        delay.time = AUValue(1.5 / playRate)
        delay.dryWetMix = 0.7
        delay.feedback = 0.9
        reverb = Reverb(delay)
        reverb.dryWetMix = 0.9
        engine.output = reverb
    }

    func start() {
        do {
            try engine.start()
            loop = CallbackLoop(frequency: playRate) {
                let scale = [60, 62, 65, 66, 67, 69, 71]
                let note1 = Int(AUValue.random(in: 0.0 ..< Float(scale.count)))
                let note2 = Int(AUValue.random(in: 0.0 ..< Float(scale.count)))
                let newAmp = AUValue.random(in: 0.0 ... 1.0)
                if AUValue.random(in: 0.0 ... 30.0) > 15 {
                    self.inst2.trigger(note: MIDINoteNumber(scale[note1]), velocity: MIDIVelocity(newAmp * 127.0))
                }
                if AUValue.random(in: 0.0 ... 30.0) > 15 {
                    self.inst3.trigger(note: MIDINoteNumber(scale[note2]), velocity: MIDIVelocity(newAmp * 127.0))
                }
                if AUValue.random(in: 0.0 ... 30.0) > 15 {
                    self.inst4.trigger(note: MIDINoteNumber(scale[note2]), velocity: MIDIVelocity(newAmp * 127.0))
                }
                if AUValue.random(in: 0.0 ... 30.0) > 15 {
                    self.inst1.frequency = scale[note1].midiNoteToFrequency()
                    self.inst1.amplitude = newAmp
                    self.inst1.trigger()
                }
            }
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
        loop.stop()
    }
}

struct PluckedStringView: View {
    @ObservedObject var conductor = PluckedStringConductor()

    var body: some View {
        VStack {
            Text(conductor.isRunning ? "Stop" : "Start")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isRunning.toggle()
            }
            NodeOutputView(conductor.reverb)
        }
        .padding()
        .cookbookNavBarTitle("Plucked String")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
