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

let strShortPercStab = """
{"reverbToggled":0,"crushFreq":48000,"widen":0,"vco1Volume":0.800000011920929,"vco1Semitone":0,"tempoSyncToArpRate":1,"phaserMix":0,"lfoWaveform":0,"compressorMasterRelease":0.15000000596046448,"uid":"16140407-3984-408B-9EF5-DFB7D00E19BA","fmAmount":0,"decayLFO":0,"fmVolume":0.0024999999441206455,"delayInputResonance":0,"compressorReverbInputAttack":0.0010000000474974513,"category":1,"vco2Detuning":0.3400000035762787,"pitchbendMaxSemitones":12,"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"autoPanAmount":0.007111129816621542,"lfo2Waveform":0,"seqNoteOn":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],"compressorReverbWetAttack":0.0010000000474974513,"compressorReverbWetRelease":0.15000000596046448,"compressorReverbInputThreshold":-8.5,"releaseDuration":0.09944000095129013,"filterType":0,"phaserFeedback":0,"compressorReverbWetRatio":13,"compressorReverbWetThreshold":-8,"filterADSRMix":0.9960000514984131,"waveform2":1,"arpIsSequencer":true,"isFavorite":true,"name":"Short Perc Stab Pluck JFU","oscBandlimitEnable":0,"reverbMix":0.14249998331069946,"pitchbendMinSemitones":-12,"compressorReverbInputRelease":0.22499999403953552,"reverbHighPass":305.5,"waveform1":0.37371134757995605,"vcoBalance":0.5,"fmLFO":0,"delayMix":0.16124987602233887,"delayToggled":0,"decayDuration":0.14349998533725739,"arpOctave":0,"compressorReverbWetMakeupGain":1.8799999952316284,"arpTotalSteps":8,"vco2Volume":0.800000011920929,"author":"","attackDuration":0.005498750135302544,"isHoldMode":1,"arpInterval":12,"adsrPitchTracking":1,"compressorMasterAttack":0.0010000000474974513,"delayTime":0.3333333134651184,"frequencyA4":440,"reverbMixLFO":0,"arpRate":90,"delayFeedback":0.19449999928474426,"resonanceLFO":0,"compressorReverbInputRatio":13,"lfoAmplitude":0.839999794960022,"subOscSquareToggled":0,"filterAttack":0.0005000000237487257,"isArpMode":0,"compressorReverbInputMakeupGain":1.8799999952316284,"seqPatternNote":[0,4,7,11,12,11,7,4,0,0,0,0,0,0,0,0],"tremoloLFO":0,"arpDirection":0,"filterRelease":0.5,"oscMixLFO":0,"reverbFeedback":0.7443000078201294,"lfo2Amplitude":1,"isLegato":0,"vco2Semitone":0,"cutoff":3862.358642578125,"lfo2Rate":0.3750000298023224,"compressorMasterThreshold":-9,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"autoPanFrequency":0.1875000149011612,"resonance":0.10000000149011612,"userText":"AudioKit Synth One preset. Press and hold middle “C”. It sounds strangly familiar. Preset by M Y S T E R Y guest","pitchLFO":0,"isUser":true,"cutoffLFO":0,"arpSeqTempoMultiplier":0.25,"bank":"BankA","masterVolume":1.100000023841858,"tuningName":"12 ET","filterSustain":0,"phaserNotchWidth":800,"lfoRate":0.1875000149011612,"position":110,"isMono":0,"bitcrushLFO":0,"midiBendRange":2,"detuneLFO":0,"transpose":0,"delayInputCutoffTrackingRatio":0.75,"compressorMasterRatio":20,"filterEnvLFO":0,"modWheelRouting":0,"subOsc24Toggled":0,"subVolume":0.11249999701976776,"glide":0,"filterDecay":0.10474999994039536,"noiseLFO":0,"phaserRate":12,"compressorMasterMakeupGain":2,"octavePosition":0,"noiseVolume":0,"sustainLevel":0.1339999884366989}
"""

// makes weird pops and doesn't work at all
//let strBabyRobotMusicbox3 = """
//{"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"vco2Volume":0.800000011920929,"reverbMixLFO":0,"compressorMasterMakeupGain":2,"oscMixLFO":0,"lfo2Rate":0.03177083656191826,"waveform2":0.2575107216835022,"tuningName":"12 ET","fmAmount":0,"fmVolume":0,"glide":0,"isUser":true,"frequencyA4":440,"tremoloLFO":0,"noiseVolume":0,"delayMix":0.21375000476837158,"tempoSyncToArpRate":1,"filterType":0,"compressorMasterThreshold":-9,"userText":"AudioKit Synth One. Step. By. Step. The Robot lives inside us all. Marching to their own beat. Seldom in  4/4 time, they march on... by Matthew Fecher","pitchLFO":0,"delayInputCutoffTrackingRatio":0.75,"delayTime":0.9836064577102661,"lfoRate":2.0333335399627686,"reverbHighPass":80,"isFavorite":true,"isLegato":0,"subOsc24Toggled":0,"lfoWaveform":0,"arpDirection":0,"phaserNotchWidth":800,"bitcrushLFO":0,"adsrPitchTracking":1.002466457663103938,"filterRelease":0.0949999988079071,"bank":"BankA","widen":0,"lfo2Waveform":0,"cutoff":6976.79736328125,"oscBandlimitEnable":0,"position":80,"filterADSRMix":1.1886223554611206,"arpInterval":12,"compressorReverbInputAttack":0.0010000000474974513,"reverbToggled":0,"subOscSquareToggled":0,"isHoldMode":0,"crushFreq":48000,"seqPatternNote":[0,0,12,12,0,-12,0,4,0,0,0,0,0,0,0,0],"compressorReverbWetAttack":0.0010000000474974513,"arpTotalSteps":7,"pitchbendMinSemitones":-12,"subVolume":0,"arpOctave":0,"modWheelRouting":0,"isMono":0,"phaserMix":0,"arpSeqTempoMultiplier":0.25,"filterEnvLFO":0,"compressorReverbWetRelease":0.15000000596046448,"vco2Detuning":-3.469446951953614e-17,"compressorReverbInputRatio":13,"seqNoteOn":[true,false,true,false,true,true,false,false,true,true,true,true,true,true,true,true],"compressorReverbInputMakeupGain":1.8799999952316284,"compressorReverbInputThreshold":-8.5,"delayInputResonance":0,"pitchbendMaxSemitones":12,"sustainLevel":0.02133338898420334,"resonanceLFO":0,"vco2Semitone":0,"uid":"5F6075F8-8924-4659-8748-3D3E1ED50D79","arpIsSequencer":true,"vcoBalance":0.5,"lfoAmplitude":0,"delayFeedback":0.10000000149011612,"lfo2Amplitude":0,"vco1Semitone":0,"resonance":0.10000000149011612,"name":"Baby Robot Musicbox JFU 3","waveform1":0.04908376932144165,"noiseLFO":0,"reverbFeedback":0.4653500020503998,"compressorMasterRatio":20,"vco1Volume":0.800000011920929,"midiBendRange":2,"autoPanFrequency":0.25416669249534607,"decayLFO":0,"octavePosition":1,"masterVolume":1.7699997425079346,"transpose":0,"compressorReverbWetMakeupGain":1.8799999952316284,"author":"","isArpMode":0,"cutoffLFO":0,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"detuneLFO":0,"filterDecay":0.4343355894088745,"compressorReverbWetRatio":13,"releaseDuration":0.6048699617385864,"delayToggled":0,"reverbMix":0.13750000298023224,"category":1,"compressorReverbInputRelease":0.22499999403953552,"phaserFeedback":0,"filterAttack":0.0005000000237487257,"decayDuration":0.4425642192363739,"fmLFO":0,"compressorMasterAttack":0.0010000000474974513,"arpRate":61,"compressorReverbWetThreshold":-8,"attackDuration":0.0005000000237487257,"compressorMasterRelease":0.15000000596046448,"phaserRate":12,"autoPanAmount":0,"filterSustain":0.10966663807630539}
//"""

// low notes are way too quiet. masterVolume stills seems too low after boosting it ... ?
// are we missing some sort of compressor that is running automatically in AKSynthOne?
let strBrassyEP = """
{"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"vco2Volume":0.20512962341308594,"reverbMixLFO":2,"compressorMasterMakeupGain":2,"oscMixLFO":0,"lfo2Rate":0.8875000476837158,"waveform2":0,"tuningName":"12 ET","fmAmount":0,"fmVolume":0,"glide":0,"isUser":true,"frequencyA4":440,"tremoloLFO":0,"noiseVolume":0,"delayMix":0.11250004917383194,"tempoSyncToArpRate":1,"filterType":0,"compressorMasterThreshold":-9,"userText":"AudioKit Synth One preset. Modern poly sound for fun! Play some chords. Preset by Matthew Fecher","pitchLFO":0,"delayInputCutoffTrackingRatio":0.75,"delayTime":0.563380241394043,"lfoRate":0.4437500238418579,"reverbHighPass":401.8500061035156,"isFavorite":true,"isLegato":0,"subOsc24Toggled":0,"lfoWaveform":0,"arpDirection":0,"phaserNotchWidth":525.25,"bitcrushLFO":0,"adsrPitchTracking":1,"filterRelease":0.2581128776073456,"bank":"BankA","widen":0,"lfo2Waveform":0,"cutoff":5257.71142578125,"oscBandlimitEnable":0,"position":71,"filterADSRMix":0.9566890597343445,"arpInterval":12,"compressorReverbInputAttack":0.0010000000474974513,"reverbToggled":0,"subOscSquareToggled":0,"isHoldMode":0,"crushFreq":48000,"seqPatternNote":[0,-12,0,4,0,-12,0,5,0,0,0,0,0,0,0,0],"compressorReverbWetAttack":0.0010000000474974513,"arpTotalSteps":8,"pitchbendMinSemitones":-12,"subVolume":0.11749999970197678,"arpOctave":2,"modWheelRouting":0,"isMono":0,"phaserMix":0.765536904335022,"arpSeqTempoMultiplier":0.25,"filterEnvLFO":0,"compressorReverbWetRelease":0.15000000596046448,"vco2Detuning":0.20000003278255463,"compressorReverbInputRatio":13,"seqNoteOn":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],"compressorReverbInputMakeupGain":1.8799999952316284,"compressorReverbInputThreshold":-8.5,"delayInputResonance":0,"pitchbendMaxSemitones":12,"sustainLevel":0.1932036131620407,"resonanceLFO":0,"vco2Semitone":7,"uid":"D2162591-C6EE-414A-B87F-0C59A9ADAD23","arpIsSequencer":false,"vcoBalance":0.4925000071525574,"lfoAmplitude":0.14249999821186066,"delayFeedback":0.2474999576807022,"lfo2Amplitude":0.5624999403953552,"vco1Semitone":0,"resonance":0.4777500033378601,"name":"Brassy EP JFU","waveform1":0,"noiseLFO":0,"reverbFeedback":0.6762747168540955,"compressorMasterRatio":20,"vco1Volume":0.32499998807907104,"midiBendRange":2,"autoPanFrequency":0.2958333492279053,"decayLFO":0,"octavePosition":1,"masterVolume":2.8524999618530273,"transpose":0,"compressorReverbWetMakeupGain":1.8799999952316284,"author":"","isArpMode":0,"cutoffLFO":1,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"detuneLFO":0,"filterDecay":0.5196621417999268,"compressorReverbWetRatio":13,"releaseDuration":0.5927701592445374,"delayToggled":0,"reverbMix":0.09000003337860107,"category":1,"compressorReverbInputRelease":0.22499999403953552,"phaserFeedback":0.34199997782707214,"filterAttack":0.0384165421128273,"decayDuration":0.6021074056625366,"fmLFO":0,"compressorMasterAttack":0.0010000000474974513,"arpRate":71,"compressorReverbWetThreshold":-8,"attackDuration":0.005239568185061216,"compressorMasterRelease":0.15000000596046448,"phaserRate":12,"autoPanAmount":0.030814819037914276,"filterSustain":0.12990745902061462}
"""


let strSnake3 = """
{"bank":"BankA","vco2Detuning":-3.469446951953614e-17,"attackDuration":0.005498750135302544,"filterDecay":0.0625,"subOscSquareToggled":0,"reverbFeedback":0.4653500020503998,"filterType":0,"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"releaseDuration":0.12000000189989805,"autoPanAmount":0,"pitchLFO":0,"pitchbendMaxSemitones":12,"delayInputResonance":0,"waveform2":0.2575107216835022,"compressorReverbWetRelease":0.15000000596046448,"modWheelRouting":0,"tempoSyncToArpRate":1,"lfo2Amplitude":0.016666000708937645,"compressorReverbInputAttack":0.0010000000474974513,"autoPanFrequency":0.2569444477558136,"glide":0,"arpInterval":12,"uid":"BCC30B44-EA27-4DE6-9CEC-D76786BE4774","compressorReverbInputThreshold":-8.5,"delayToggled":0,"compressorMasterRatio":20,"phaserRate":12,"noiseVolume":0.18607406318187714,"midiBendRange":2,"compressorMasterRelease":0.15000000596046448,"vco2Volume":0.800000011920929,"reverbHighPass":700,"frequencyA4":440,"lfoAmplitude":0,"resonanceLFO":0,"fmVolume":0,"detuneLFO":0,"subOsc24Toggled":1,"tremoloLFO":0,"fmAmount":0,"phaserFeedback":0,"sustainLevel":0,"filterSustain":1,"arpTotalSteps":8,"crushFreq":48000,"pitchbendMinSemitones":-12,"lfo2Waveform":0,"vco2Semitone":19,"category":4,"resonance":0.10000000149011612,"delayInputCutoffTrackingRatio":0.75,"reverbMix":0.23499999940395355,"filterEnvLFO":0,"widen":0,"position":74,"filterAttack":0.0005000000237487257,"decayDuration":0.12099999934434891,"vco1Semitone":0,"compressorReverbWetRatio":13,"compressorReverbInputMakeupGain":1.8799999952316284,"userText":"AudioKit Synth One preset. Nice lead dance pluck. Preset by Matthew Fecher","lfo2Rate":0.0963541716337204,"filterRelease":0.0949999988079071,"isHoldMode":0,"seqPatternNote":[0,0,12,12,0,-12,0,4,0,0,0,0,0,0,0,0],"transpose":0,"isMono":0,"cutoff":4600.3251953125,"noiseLFO":0,"isFavorite":true,"compressorMasterMakeupGain":2,"isUser":true,"delayTime":0.1621621549129486,"arpOctave":0,"compressorReverbInputRatio":13,"masterVolume":1.715000033378601,"vcoBalance":0.5,"octavePosition":1,"delayMix":0.17812499403953552,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"compressorReverbWetThreshold":-8,"seqNoteOn":[true,false,true,false,true,true,false,false,true,true,true,true,true,true,true,true],"decayLFO":0,"fmLFO":0,"delayFeedback":0.23274999856948853,"reverbMixLFO":0,"cutoffLFO":0,"compressorMasterThreshold":-9,"compressorReverbInputRelease":0.22499999403953552,"compressorReverbWetMakeupGain":1.8799999952316284,"filterADSRMix":1,"arpSeqTempoMultiplier":0.25,"lfoRate":0.0963541716337204,"compressorReverbWetAttack":0.0010000000474974513,"arpRate":185,"name":"Snake w Rev+Delay JFU 3","arpDirection":0,"reverbToggled":0,"oscBandlimitEnable":0,"oscMixLFO":0,"subVolume":0.4749999940395355,"isArpMode":0,"phaserMix":0,"lfoWaveform":0,"compressorMasterAttack":0.0010000000474974513,"waveform1":0.04908376932144165,"author":"","phaserNotchWidth":800,"arpIsSequencer":true,"adsrPitchTracking":1,"tuningName":"12 ET","isLegato":0,"vco1Volume":0.800000011920929,"bitcrushLFO":0}
"""

let strBrightOrgan3 = """
{"bitcrushLFO":0,"filterRelease":0.5051110982894897,"tuningName":"12 ET","seqPatternNote":[0,-12,12,5,4,12,5,4,0,0,0,0,0,0,0,0],"compressorReverbWetRelease":0.15000000596046448,"midiBendRange":2,"cutoff":22050,"subVolume":0.1224999949336052,"filterType":0,"modWheelRouting":0,"autoPanAmount":0.14499999582767487,"compressorMasterMakeupGain":2,"compressorMasterRatio":20,"filterADSRMix":0.08035492151975632,"tempoSyncToArpRate":1,"waveform1":0,"autoPanFrequency":0.5,"compressorReverbInputRatio":13,"arpSeqTempoMultiplier":0.25,"delayInputResonance":0,"decayDuration":0.35208356380462646,"crushFreq":48000,"reverbHighPass":114.8499984741211,"compressorReverbInputAttack":0.0010000000474974513,"compressorReverbWetAttack":0.0010000000474974513,"compressorMasterRelease":0.15000000596046448,"compressorReverbInputMakeupGain":1.8799999952316284,"reverbFeedback":0.8474999666213989,"vco2Semitone":24,"lfoRate":0.0625,"compressorReverbWetRatio":13,"seqNoteOn":[true,false,true,true,true,true,true,true,true,true,true,true,true,true,true,true],"compressorMasterAttack":0.0010000000474974513,"isMono":0,"detuneLFO":0,"isUser":true,"reverbMix":0.15500015020370483,"name":"Bright Organ EP 3","compressorReverbInputThreshold":-8.5,"compressorReverbInputRelease":0.22499999403953552,"delayMix":0.21937499940395355,"arpDirection":0,"compressorMasterThreshold":-9,"reverbToggled":0,"noiseVolume":0,"position":60,"filterDecay":0.25249993801116943,"isHoldMode":0,"isArpMode":0,"userText":"AudioKit Synth One preset. An organ built into a dark building?  Played by someone sinister... Preset by Fecher","fmVolume":0.7925000190734863,"transpose":0,"lfo2Amplitude":0.2574999928474426,"pitchbendMaxSemitones":12,"filterSustain":0.28070372343063354,"decayLFO":0,"frequencyA4":440,"category":2,"arpOctave":2,"attackDuration":0.005498750135302544,"delayToggled":0,"subOscSquareToggled":0,"vco2Detuning":-1.0399999618530273,"waveform2":0.16524748504161835,"adsrPitchTracking":1,"isLegato":0,"lfo2Waveform":0,"delayInputCutoffTrackingRatio":0.75,"vco2Volume":0.8600000143051147,"tremoloLFO":0,"phaserNotchWidth":800,"lfo2Rate":4,"filterAttack":0.0104975001886487,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"arpInterval":12,"reverbMixLFO":0,"cutoffLFO":0,"fmLFO":0,"resonanceLFO":0,"phaserFeedback":0,"filterEnvLFO":0,"lfoWaveform":0,"bank":"BankA","noiseLFO":0,"subOsc24Toggled":0,"sustainLevel":0.09662987291812897,"pitchbendMinSemitones":-12,"compressorReverbWetMakeupGain":1.8799999952316284,"vco1Volume":0.8450000286102295,"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"octavePosition":0,"uid":"028EE6D9-1EAE-4F66-A0BB-8FAC5EA9E90E","releaseDuration":0.6805700063705444,"isFavorite":true,"phaserMix":0,"arpIsSequencer":false,"delayFeedback":0.2214999943971634,"widen":0,"vcoBalance":0.32499998807907104,"masterVolume":0.19249999523162842,"author":"","arpTotalSteps":8,"vco1Semitone":12,"glide":0,"resonance":0.10000000149011612,"delayTime":0.0833333283662796,"compressorReverbWetThreshold":-8,"pitchLFO":0,"oscMixLFO":0,"fmAmount":0,"arpRate":120,"lfoAmplitude":0,"phaserRate":12,"oscBandlimitEnable":0}
"""

let strPluckYou3 = """
{"reverbToggled":1,"reverbHighPass":149.6999969482422,"compressorReverbInputMakeupGain":0.5,"phaserFeedback":0,"releaseDuration":0.05000000074505806,"tempoSyncToArpRate":1,"resonanceLFO":0,"lfoRate":1,"compressorMasterThreshold":0,"compressorReverbWetRelease":0,"arpRate":120,"name":"Pluck you 3 JFU","tuningName":"12 ET","compressorReverbWetRatio":1,"arpInterval":12,"oscBandlimitEnable":0,"filterEnvLFO":0,"userText":"AudioKit Synth One. \nPreset by Sound of Izrael","author":"","cutoffLFO":0,"adsrPitchTracking":1,"frequencyA4":440,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"delayMix":0.5,"seqPatternNote":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"subOsc24Toggled":0,"sustainLevel":0,"compressorMasterMakeupGain":0.5,"modWheelRouting":0,"compressorMasterRatio":1,"widen":0,"vco2Volume":0.75,"attackDuration":0.0005000000237487257,"filterADSRMix":0.44700002670288086,"vco1Semitone":0,"compressorReverbInputAttack":0,"isMono":0,"masterVolume":0.5,"phaserNotchWidth":800,"lfoAmplitude":0.3199999928474426,"compressorReverbInputRatio":1,"crushFreq":48000,"waveform2":0.3434579372406006,"transpose":0,"noiseVolume":0.015625,"category":6,"delayInputResonance":0,"compressorReverbWetAttack":0,"reverbFeedback":0.7300000190734863,"bitcrushLFO":0,"arpSeqTempoMultiplier":0.25,"isFavorite":true,"cutoff":2000,"delayFeedback":0.10000000149011612,"vcoBalance":0.5,"arpOctave":1,"isHoldMode":0,"arpDirection":0,"lfo2Waveform":0,"reverbMix":0.22750000655651093,"subVolume":0.03555557131767273,"vco1Volume":0.75,"lfo2Rate":3.000000238418579,"tremoloLFO":0,"compressorReverbInputThreshold":0,"isLegato":0,"fmAmount":9.975000381469727,"isUser":true,"pitchLFO":0,"decayLFO":0,"phaserMix":0,"compressorReverbWetMakeupGain":0.5,"bank":"Sound of Izrael","vco2Detuning":0,"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"vco2Semitone":12,"filterDecay":0.8735823035240173,"phaserRate":12,"fmLFO":0,"noiseLFO":0,"decayDuration":0.6385250091552734,"autoPanAmount":0,"resonance":0.10000000149011612,"oscMixLFO":0,"isArpMode":0,"uid":"848BA35B-57A0-4ECC-A4CE-1B9931D3CB5B","arpTotalSteps":8,"subOscSquareToggled":0,"delayToggled":0,"reverbMixLFO":0,"delayTime":0.3333333134651184,"pitchbendMaxSemitones":0,"position":50,"glide":0,"midiBendRange":2,"pitchbendMinSemitones":0,"lfo2Amplitude":0.4925000071525574,"seqNoteOn":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],"filterSustain":1,"detuneLFO":0,"filterRelease":0.14499999582767487,"octavePosition":0,"compressorMasterAttack":0,"autoPanFrequency":0.25,"filterAttack":0.0005000000237487257,"lfoWaveform":1,"fmVolume":0.4000000059604645,"compressorMasterRelease":0,"compressorReverbInputRelease":0,"delayInputCutoffTrackingRatio":0.75,"filterType":0,"compressorReverbWetThreshold":0,"arpIsSequencer":false,"waveform1":0}
"""

let strTotallyTubular3 = """
{"noiseLFO":0,"vco2Detuning":0.9399999976158142,"filterADSRMix":0.8928000330924988,"compressorMasterMakeupGain":2,"cutoffLFO":0,"compressorReverbInputThreshold":-8.5,"detuneLFO":0,"uid":"F3A8BE55-B17A-404F-AF65-336B5F7BDA15","oscBandlimitEnable":0,"octavePosition":0,"lfo2Waveform":0,"lfo2Amplitude":0.8366659879684448,"fmAmount":0.10666580498218536,"cutoff":8419.37890625,"crushFreq":48000,"arpTotalSteps":16,"compressorReverbWetRelease":0.15000000596046448,"lfoAmplitude":0.4962500035762787,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"arpInterval":3,"seqOctBoost":[false,false,false,false,false,false,true,false,false,false,false,true,false,false,true,true],"compressorReverbWetRatio":13,"compressorReverbWetThreshold":-8,"arpSeqTempoMultiplier":0.25,"delayMix":0.171875,"sustainLevel":0.014222259633243084,"tuningName":"12 ET","compressorReverbWetAttack":0.0010000000474974513,"vco1Semitone":0,"filterRelease":0.15649987757205963,"compressorReverbInputRelease":0.22499999403953552,"category":1,"midiBendRange":2,"filterAttack":0.0005000000237487257,"vco1Volume":0.800000011920929,"resonance":0.10000000149011612,"vco2Semitone":12,"oscMixLFO":0,"reverbHighPass":442.3374938964844,"filterDecay":0.39729341864585876,"filterEnvLFO":0,"delayTime":0.3030302822589874,"seqPatternNote":[0,-5,-7,-12,-7,0,7,0,-12,0,-2,-7,-12,0,12,3],"compressorMasterRelease":0.15000000596046448,"isHoldMode":0,"compressorReverbInputRatio":13,"subOscSquareToggled":0,"adsrPitchTracking":1,"isFavorite":true,"filterType":0,"autoPanFrequency":0.20625001192092896,"subOsc24Toggled":0,"reverbMix":0.11000000685453415,"attackDuration":0.0005000000237487257,"noiseVolume":0,"pitchbendMaxSemitones":12,"reverbFeedback":0.6196499466896057,"pitchLFO":0,"resonanceLFO":0,"masterVolume":0.6550000309944153,"glide":0,"phaserMix":0,"delayInputCutoffTrackingRatio":0.75,"tempoSyncToArpRate":1,"waveform2":0.28738316893577576,"compressorReverbInputMakeupGain":1.8799999952316284,"phaserRate":12,"lfoWaveform":0,"lfo2Rate":0.13750001788139343,"arpOctave":1,"isArpMode":0,"userText":"AudioKit Synth One preset. Twist the knobs to indulge your analog desires. \nPreset by by Matthew Feccher","widen":0,"seqNoteOn":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],"modWheelRouting":0,"arpIsSequencer":true,"frequencyA4":440,"releaseDuration":0.39031898975372314,"bitcrushLFO":0,"delayInputResonance":0,"delayFeedback":0.10000000149011612,"name":"Totally Tubular JFU 3","author":"","reverbMixLFO":0,"isLegato":0,"arpDirection":0,"filterSustain":0,"fmVolume":0.052148208022117615,"fmLFO":0,"phaserNotchWidth":800,"arpRate":99,"isMono":0,"compressorMasterRatio":20,"tremoloLFO":0,"isUser":true,"compressorMasterAttack":0.0010000000474974513,"phaserFeedback":0,"vcoBalance":0,"bank":"BankA","compressorReverbWetMakeupGain":1.8799999952316284,"lfoRate":0.4125000238418579,"autoPanAmount":0.014222183264791965,"transpose":0,"compressorMasterThreshold":-9,"compressorReverbInputAttack":0.0010000000474974513,"position":48,"delayToggled":0,"decayDuration":0.5167812705039978,"pitchbendMinSemitones":-12,"waveform1":0.25,"subVolume":0.40087035298347473,"decayLFO":0,"vco2Volume":0.800000011920929,"reverbToggled":0}
"""

let strElectricBanjo = """
{"vco2Detuning":0,"arpSeqTempoMultiplier":0.25,"delayMix":0.10499999672174454,"tremoloLFO":0,"lfo2Waveform":0,"compressorMasterAttack":0.0010000000474974513,"modWheelRouting":0,"waveform1":0.688144326210022,"lfo2Amplitude":0,"fmLFO":0,"reverbToggled":0,"resonance":0.3625999987125397,"fmVolume":0,"position":123,"delayTime":0.10000000149011612,"decayLFO":0,"subOsc24Toggled":0,"userText":"AudioKit Synth One preset. This is a sound from those classic toy keyboards. \nPreset by Matthew Fecher","octavePosition":0,"reverbHighPass":700,"uid":"5D969D1E-896F-4F2F-99F5-F42DEA4BAC84","compressorReverbInputAttack":0.0010000000474974513,"compressorMasterMakeupGain":2,"filterAttack":0.0005000000237487257,"masterVolume":0.3400000035762787,"compressorMasterRatio":20,"attackDuration":0.0005000000237487257,"waveform2":0.6144859790802002,"lfoAmplitude":0,"arpRate":148,"vco2Volume":0,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"compressorReverbInputRelease":0.22499999403953552,"category":6,"compressorReverbInputRatio":13,"compressorMasterThreshold":-9,"pitchbendMaxSemitones":12,"lfo2Rate":0.0005208333604969084,"compressorReverbWetThreshold":-8,"autoPanFrequency":0.25,"compressorReverbInputThreshold":-8.5,"vco1Semitone":0,"pitchLFO":0,"compressorReverbInputMakeupGain":1.8799999952316284,"vcoBalance":0,"resonanceLFO":0,"releaseDuration":0.019999999552965164,"fmAmount":0,"phaserFeedback":0,"seqNoteOn":[true,true,true,false,true,true,false,true,true,true,true,true,true,true,true,true],"seqPatternNote":[0,0,-12,0,0,0,0,0,0,0,0,0,0,0,0,0],"arpDirection":1,"autoPanAmount":0,"decayDuration":0.11550000309944153,"compressorReverbWetMakeupGain":1.8799999952316284,"widen":0,"filterType":0,"bank":"BankA","compressorReverbWetAttack":0.0010000000474974513,"oscMixLFO":0,"arpInterval":12,"arpIsSequencer":false,"isMono":0,"lfoRate":0.0005208333604969084,"pitchbendMinSemitones":-12,"name":"Cazio Banjo Pluck 2","bitcrushLFO":0,"compressorReverbWetRelease":0.15000000596046448,"frequencyA4":440,"adsrPitchTracking":1,"compressorMasterRelease":0.15000000596046448,"reverbMixLFO":0,"filterEnvLFO":0,"phaserMix":0,"delayToggled":0,"detuneLFO":0,"cutoff":6516.8828125,"delayInputCutoffTrackingRatio":0.75,"subVolume":0.0024999999441206455,"filterSustain":0.414000004529953,"transpose":0,"midiBendRange":2,"noiseLFO":0,"isHoldMode":0,"sustainLevel":0,"crushFreq":48000,"reverbMix":0.0949999988079071,"filterRelease":0.05000000074505806,"filterDecay":0.25600001215934753,"tempoSyncToArpRate":0,"arpTotalSteps":8,"author":"","noiseVolume":0.14103704690933228,"delayInputResonance":0,"isFavorite":false,"filterADSRMix":1,"phaserNotchWidth":800,"vco2Semitone":0,"arpOctave":0,"glide":0,"compressorReverbWetRatio":13,"reverbFeedback":0.392924964427948,"tuningName":"12 ET","isLegato":0,"cutoffLFO":0,"subOscSquareToggled":0,"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"lfoWaveform":0,"phaserRate":12,"isUser":true,"isArpMode":0,"vco1Volume":0.800000011920929,"delayFeedback":0.10000000149011612,"oscBandlimitEnable":0}
"""

let strPureFMPluck = """
{"isLegato":0,"reverbHighPass":700,"compressorMasterAttack":0.0010000000474974513,"tuningMasterSet":[1,1.0594630943592953,1.122462048309373,1.189207115002721,1.2599210498948732,1.3348398541700344,1.4142135623730951,1.4983070768766815,1.5874010519681994,1.681792830507429,1.7817974362806785,1.8877486253633868],"attackDuration":0.0104975001886487,"oscBandlimitEnable":0,"compressorMasterThreshold":-9,"filterAttack":0.0005000000237487257,"waveform2":0.1386638879776001,"releaseDuration":0.02016128972172737,"arpIsSequencer":false,"isArpMode":0,"reverbMixLFO":0,"midiBendRange":2,"arpRate":113,"oscMixLFO":0,"isHoldMode":0,"lfo2Amplitude":0.016666000708937645,"vco1Volume":0,"noiseVolume":0,"compressorReverbWetMakeupGain":1.8799999952316284,"tuningName":"12 ET","delayInputResonance":0,"cutoffLFO":0,"pitchbendMaxSemitones":12,"filterEnvLFO":0,"transpose":0,"reverbToggled":0,"arpInterval":8,"seqOctBoost":[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],"compressorReverbInputRatio":13,"isUser":true,"compressorReverbWetAttack":0.0010000000474974513,"fmVolume":1,"subOscSquareToggled":0,"tremoloLFO":0,"decayLFO":0,"filterType":0,"resonanceLFO":0,"uid":"6E2AE9EF-B062-4B4F-AD43-803CDDA8BAE0","subOsc24Toggled":0,"filterADSRMix":0.2958221733570099,"category":6,"phaserNotchWidth":800,"filterDecay":0.5630089640617371,"crushFreq":48000,"vco2Detuning":0,"isFavorite":true,"sustainLevel":0,"autoPanFrequency":0.25,"modWheelRouting":0,"vco2Volume":0,"reverbFeedback":0.6621999740600586,"compressorReverbWetThreshold":-8,"compressorMasterRatio":20,"lfoRate":0.0005208333604969084,"octavePosition":1,"autoPanAmount":0,"widen":0,"resonance":0.10000000149011612,"phaserRate":12,"fmLFO":0,"phaserMix":0,"tempoSyncToArpRate":0,"filterRelease":0.37237030267715454,"delayTime":0.5309734344482422,"arpTotalSteps":8,"lfo2Rate":0.0005208333604969084,"glide":0,"noiseLFO":0,"arpSeqTempoMultiplier":0.25,"lfoAmplitude":0.13037040829658508,"compressorReverbInputAttack":0.0010000000474974513,"delayFeedback":0.10000000149011612,"compressorReverbWetRatio":13,"fmAmount":0,"cutoff":10878.21875,"delayToggled":0,"masterVolume":0.42750000953674316,"isMono":0,"pitchbendMinSemitones":-12,"phaserFeedback":0,"compressorMasterRelease":0.15000000596046448,"lfo2Waveform":0,"compressorReverbInputRelease":0.22499999403953552,"compressorReverbInputThreshold":-8.5,"compressorMasterMakeupGain":2,"reverbMix":0.21250000596046448,"decayDuration":0.18709677457809448,"delayMix":0.06187500059604645,"name":"Pure FM Pluck 2","subVolume":0.030814895406365395,"adsrPitchTracking":1,"frequencyA4":440,"lfoWaveform":0,"delayInputCutoffTrackingRatio":0.75,"bitcrushLFO":0,"vcoBalance":0.5,"userText":"AudioKit Synth One preset. An FM pluck sound unsullied by DCOs. \nPreset by Matthew Fecher","detuneLFO":0,"arpOctave":1,"seqPatternNote":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"pitchLFO":0,"seqNoteOn":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],"arpDirection":2,"compressorReverbWetRelease":0.15000000596046448,"vco2Semitone":-12,"waveform1":0,"bank":"BankA","position":129,"author":"","compressorReverbInputMakeupGain":1.8799999952316284,"filterSustain":0.40977776050567627,"vco1Semitone":0}
"""

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
  \(filterADSRMix)
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

class S1GeneratorBank {
    var vco1 = MorphingOscillator()
    var vco2 = MorphingOscillator()
    var fmOsc = FMOscillator()
    var subOsc: Oscillator
    
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

        bankMixer = Mixer(vcoBalancer, fmOscMixer, subMixer)
        
        filter = OperationEffect(bankMixer, sporth: synth1Preset.moogFilterEnvAmpEnvSporth)

        masterVolume = synth1Preset.masterVolume
        filterMixer = Mixer(filter)
        filterMixer.volume = masterVolume

        output = filterMixer
        
        vco1.start()
        vco2.start()
        fmOsc.start()
        subOsc.start()
        filter.start()
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
    let synth1Preset: Synth1Preset = try! JSONDecoder().decode(Synth1Preset.self, from: jsonData)
    print("synth1Preset: \(synth1Preset)")
    return synth1Preset
}

// 1b. Make folder w like 24 to 30 presets from iPad, in it
// 1c. adjust relative mastVolume levels to make switching less dramatic
// demo for Royal and the kids

// easy!
// 2. Noise osc / noise gen too

// 3. LFO too?
// 4. Phaser too?
// 5. Auto-pan or widen (will be in Pianos app, not S1Preset player)

// list of things not supported by design   (piano / pluck focused):
// - portamento e.g. mono v. poly (only poly)
// - arp / seq
// - tuning tables
// - bitcrush

// - reverb (will be in Pianos app, not S1Preset player)
// - delay  (will be in Pianos app, not S1Preset player)

// NOT in SynthOne, right?
// - EQ     (will be in Pianos app, not S1Preset player)
// - compressor? in Pianos app, not S1Preset player   <-- maybe in AKS1, not sure

// polyphony implmented here
class SynthOneConductor: ObservableObject, Noter {
    //var engine = AudioEngine()
    let s1gens: [S1GeneratorBank]
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
                s1gens[nextGenMinusOne].noteOff(pitch: pitch)
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
                s1gens[slatedForRemoval].noteOff(pitch: pitch)
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
        s1gens[index].noteOn(pitch: pitch, point: point)
        keyDownTracker[p] = index
        print("*** keys down: \(keyDownTracker.count)")
    }

    func noteOff(pitch: Pitch) {
        let p = Int(pitch.midiNoteNumber)
        if let index = keyDownTracker[p] {
            s1gens[index].noteOff(pitch: pitch)
            keyDownTracker.removeValue(forKey: p)
        }
    }
    
    func stop() {
        
    }
    
    var output: Node

//    @Published var isPlaying: Bool = false {
//        didSet { isPlaying ? osc.start() : osc.stop() }
//    }
    
    var polyMixer: Mixer
    
    let MAX_POLY = 16

    init(_ str: String) {
        let s1preset = JSONToPreset(str)
        
        s1gens = (0 ..< MAX_POLY).map({_ in S1GeneratorBank(s1preset) })
        polyMixer = Mixer(s1gens.map({ $0.output }))
        output = polyMixer
    }
}

class S1MIDIPlayable: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
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
        do { try engine.start() } catch let err { Log(err) }
        midiConductor.start()
    }
    
    func stop() {
        engine.stop()
        midiConductor.stop()
    }
    
    init(_ noter: Noter) {
        self.noter = noter
        self.midiConductor.instrumentConductor = noter
        engine.output = noter.output
    }
}

// strBabyRobotMusicbox3
let allStrs = [strShortPercStab, strBrassyEP, strSnake3, strBrightOrgan3, strPluckYou3, strTotallyTubular3, strElectricBanjo, strPureFMPluck]
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

class PresetPickHandler: HandlesPresetPick, ObservableObject {
    var lastName = ""
    var s1player: S1MIDIPlayable
    
    init() {
        s1player = S1MIDIPlayable(SynthOneConductor(strPairs[0][1]))
    }

    func presetPicked(name: String, rhs: String) {
        lastName = name
        s1player.stop()
        s1player = S1MIDIPlayable(SynthOneConductor(rhs))
        s1player.start()
    }
    
    // for tapping or clicking, not MIDI HW KB which needs to consult sustain pedal state too
    func noteOn(pitch: Pitch, point: CGPoint) {
        s1player.noteOn(pitch: pitch, point: point)
    }

    // for tapping or clicking, not MIDI HW KB which needs to consult sustain pedal state too
    func noteOff(pitch: Pitch) {
        s1player.noteOff(pitch: pitch)
    }
    
    func start() {
        s1player.start()
    }
    
    func stop() {
        s1player.stop()
    }
}

struct SynthOneView: View {
    @StateObject var conductor: PresetPickHandler = PresetPickHandler()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        PresetPicker(handlesPicked: conductor, sources: strPairs, pickedName: strPairs[0][0])
        CookbookKeyboard(noteOn: conductor.noteOn, noteOff: conductor.noteOff)
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
