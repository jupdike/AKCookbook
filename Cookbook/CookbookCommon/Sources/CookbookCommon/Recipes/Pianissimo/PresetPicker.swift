//
//  PresetPicker.swift
//  
//
//  Created by Jared Updike on 7/13/24.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

struct PresetPicker: View {
    @Environment(\.colorScheme) var colorScheme

    var handlesPicked: HandlesPresetPick
    var sources: [[String]]
    
    @State var pickedName: String
    @State var isPlaying = false
    @State var isShowingSources = false
    @State private var dragOver = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .accentColor]), startPoint: .top, endPoint: .bottom)
                    .cornerRadius(dragOver ? 15.0 : 25.0)
                    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0.0, y: 3)

                HStack {
                    Image(systemName: dragOver ? "arrow.down.doc" : "music.note.list")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    Text(pickedName != "" ? "Selected: \(pickedName)" : "Select").foregroundColor(.white)
                        .font(.system(size: 14, weight: dragOver ? .heavy : .semibold, design: .rounded))
                }
                .padding()
            }
            .onTapGesture {
                isShowingSources.toggle()
            }

        }
        .frame(minWidth: 300, idealWidth: 350, maxWidth: 360, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .center)
        .padding()
        .sheet(isPresented: $isShowingSources,
               onDismiss: { print("finished!") },
               content: { SourceAudioSheet2(presetPicker: self) })
    }
    
    func picked(name: String, rhs: String) {
        print("Picked: \(name)")
        handlesPicked.presetPicked(name: name, rhs: rhs)
    }
}

struct SourceAudioSheet2: View {
    @Environment(\.presentationMode) var presentationMode

    var presetPicker: PresetPicker
    @State var browseFiles = false
    @State var fileURL = URL(fileURLWithPath: "")

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack(spacing: 5) {
                        ForEach(presetPicker.sources, id: \.self) { source in
                            Button(action: {
                                presetPicker.picked(name: source[0], rhs: source[1])
                                presetPicker.pickedName = source[0]
                            }) {
                                HStack {
                                    Text(source[0])
                                    Spacer()
                                    if presetPicker.pickedName == source[0] {
                                        Image(systemName: presetPicker.isPlaying ? "speaker.3.fill" : "speaker.fill")
                                    }
                                }.padding()
                            }
                        }
                    }
                }
            }
            .onDisappear {
                fileURL.stopAccessingSecurityScopedResource()
            }
            .padding(.vertical, 15)
            .navigationTitle("Pick a Preset")
            #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            #endif
        }
    }
}

