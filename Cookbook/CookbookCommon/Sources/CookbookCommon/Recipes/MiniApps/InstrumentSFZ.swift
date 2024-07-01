import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic
import DunneAudioKit


class MIDIMonitorConductor2: ObservableObject, MIDIListener {
    let midi = MIDI()
    @Published var data = MIDIMonitorData()
    @Published var isShowingMIDIReceived: Bool = false
    @Published var isToggleOn: Bool = false
    @Published var oldControllerValue: Int = 0
    @Published var midiEventType: MIDIEventType = .none
    
    var wasDown = [Bool](repeating: false, count: 128) // key track of which keeps have been pressed when isToggleOn (sustain pedal) was depressed
    var isHoldingWithFinger = [Bool](repeating: false, count: 128)

    weak var instrumentConductor: InstrumentSFZConductor?
    
    init() {
    }

    func start() {
        midi.openInput(name: "Bluetooth")
        midi.openInput()
        midi.addListener(self)
    }

    func stop() {
        midi.closeAllInputs()
        instrumentConductor?.stop()
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID _: MIDIUniqueID?,
                            timeStamp _: MIDITimeStamp?)
    {
        print("noteNumber \(noteNumber) \(noteNumber)")
        print("velocity \(velocity) \(velocity)")
        DispatchQueue.main.async {
            self.midiEventType = .noteOn
            self.isShowingMIDIReceived = true
            self.data.noteOn = Int(noteNumber)
            self.data.velocity = Int(velocity)
            self.data.channel = Int(channel)
            if self.data.velocity == 0 {
                withAnimation(.easeOut(duration: 0.4)) {
                    self.isShowingMIDIReceived = false
                }
            }
        }
        let val = CGFloat( 1.0 * CGFloat(velocity) / 127.0)
        let nn = Int(noteNumber)
        self.isHoldingWithFinger[nn] = true
        if self.isToggleOn {
            wasDown[nn] = true
        }
        self.instrumentConductor?.noteOn(pitch: Pitch(Int8(noteNumber)), point: CGPoint(x: val, y: val))
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID _: MIDIUniqueID?,
                             timeStamp _: MIDITimeStamp?)
    {
        print("noteNumber \(noteNumber) \(noteNumber)")
        print("velocity \(velocity) \(velocity)")
        DispatchQueue.main.async {
            self.midiEventType = .noteOff
            self.isShowingMIDIReceived = false
            self.data.noteOff = Int(noteNumber)
            self.data.velocity = Int(velocity)
            self.data.channel = Int(channel)
        }
        let nn = Int(noteNumber)
        self.isHoldingWithFinger[nn] = false
        if self.isToggleOn {
            self.wasDown[nn] = true
        } else {
            self.instrumentConductor?.noteOff(pitch: Pitch(Int8(noteNumber)))
        }
    }

    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        print("controller \(controller) \(value)")
        DispatchQueue.main.async {
            self.midiEventType = .continuousControl
            self.isShowingMIDIReceived = true
            self.data.controllerNumber = Int(controller)
            self.data.controllerValue = Int(value)
            self.oldControllerValue = Int(value)
            self.data.channel = Int(channel)
            if self.oldControllerValue == Int(value) {
                // Fade out the MIDI received indicator.
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.4)) {
                        self.isShowingMIDIReceived = false
                    }
                }
            }
            // Show the solid color indicator when the CC value is toggled from 0 to 127
            // Otherwise toggle it off when the CC value is toggled from 127 to 0
            // Useful for stomp box and on/off UI toggled states
            if value == 127 {
                //DispatchQueue.main.async {
                self.isToggleOn = true
                //}
            } else {
                // Fade out the Toggle On indicator.
                for i in 0 ..< 128 {
                    if self.wasDown[i] && !self.isHoldingWithFinger[i] { // do not cut off notes that are still being manually held down
                        self.instrumentConductor?.noteOff(pitch: Pitch(Int8(i)))
                    }
                    self.wasDown[i] = false
                }
                //DispatchQueue.main.async {
                self.isToggleOn = false
                //}
            }
        }
    }

    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        print("received after touch")
        DispatchQueue.main.async {
            self.data.afterTouch = Int(pressure)
            self.data.channel = Int(channel)
        }
    }

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        print("recv'd after touch \(noteNumber)")
        DispatchQueue.main.async {
            self.data.afterTouchNoteNumber = Int(noteNumber)
            self.data.afterTouch = Int(pressure)
            self.data.channel = Int(channel)
        }
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        print("midi wheel \(pitchWheelValue)")
        DispatchQueue.main.async {
            self.data.pitchWheelValue = Int(pitchWheelValue)
            self.data.channel = Int(channel)
        }
    }

    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID _: MIDIUniqueID?,
                                   timeStamp _: MIDITimeStamp?)
    {
        print("Program change \(program)")
        DispatchQueue.main.async {
            self.midiEventType = .programChange
            self.isShowingMIDIReceived = true
            self.data.programChange = Int(program)
            self.data.channel = Int(channel)
            // Fade out the MIDI received indicator, since program changes don't have a MIDI release/note off.
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.4)) {
                    self.isShowingMIDIReceived = false
                }
            }
        }
    }

    func receivedMIDISystemCommand(_: [MIDIByte],
                                   portID _: MIDIUniqueID?,
                                   timeStamp _: MIDITimeStamp?)
    {
//        print("sysex")
    }

    func receivedMIDISetupChange() {
        // Do nothing
    }

    func receivedMIDIPropertyChange(propertyChangeInfo _: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    func receivedMIDINotification(notification _: MIDINotification) {
        // Do nothing
    }
}



class InstrumentSFZConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var instrument = Sampler2()
    //var instrument2 = Sampler2()

    let cond2: MIDIMonitorConductor2
    
    var lastMidiNoteVelocty = [UInt8](repeatElement(0, count: 128))
    func noteOn(pitch: Pitch, point pt: CGPoint) {
        let vel = UInt8(127.0 * pt.x)
        self.lastMidiNoteVelocty[Int(pitch.midiNoteNumber)] = vel
        instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: vel, channel: 0)
    }
    
    func noteOff(pitch: Pitch) {
        instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
        //instrument2.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: self.lastMidiNoteVelocty[Int(pitch.midiNoteNumber)], channel: 0)
    }
    
    init() {
        // Load SFZ file with Dunne Sampler
// // // // /// // // //        if let fileURL = Bundle.main.url(forResource: "Sounds/SalGrandPiano/SalGrandPianoV3", withExtension: "sfz") {
        if let fileURL = Bundle.main.url(forResource: "Sounds/SalGrandPiano/GrandPianoV1_halfish", withExtension: "sfz") {
//        if let fileURL = Bundle.main.url(forResource: "Sounds/SalGrandPiano/StrResV1", withExtension: "sfz") {
            instrument.loadSFZ(url: fileURL)
        } else {
            Log("Could not find file 1")
        }
        instrument.masterVolume = 1.0
        instrument.releaseDuration = 0.2 // why doesn't this do anything? It sets the knob but in practice releaseDuration is still 0.0 seconds!
        //let RELEASE_DUR = 14
        //instrument.parameters[RELEASE_DUR] = 0.2 // sounds good when knob is fiddled with...

//        if let fileURL = Bundle.main.url(forResource: "Sounds/SalGrandPiano/StrResV1", withExtension: "sfz") {
//            instrument2.loadSFZ(url: fileURL)
//        } else {
//            Log("Could not find file 2")
//        }
//        instrument2.masterVolume = 0.4

        // mixer to combine output of two instruments
        //let mixer = Mixer(instrument, instrument2)
        engine.output = instrument //mixer
        //mixer.start()

        self.cond2 = MIDIMonitorConductor2()
        //self.cond2 = self
        self.cond2.instrumentConductor = self
        self.cond2.start()
        
        instrument.releaseDuration = 0.2 // why doesn't this do anything? It sets the knob but in practice releaseDuration is still 0.0 seconds!
    }
}

struct InstrumentSFZView: View {
    @StateObject var conductor = InstrumentSFZConductor()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            ForEach(0...7, id: \.self) {
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        HStack {
            ForEach(8...15, id: \.self) {
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        HStack {
            ForEach(16...23, id: \.self) {
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        HStack {
            ForEach(24...30, id: \.self) {
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        CookbookKeyboard(noteOn: conductor.noteOn,
                         noteOff: conductor.noteOff)
        .cookbookNavBarTitle("Instrument SFZ")
        .onAppear {
            conductor.start()
            conductor.instrument.releaseDuration = 0.2 // leaving this at zero sounds bad! WHEN do we need to set this?
        }
        .onDisappear {
            conductor.stop()
        }
        .background(colorScheme == .dark ?
                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}
