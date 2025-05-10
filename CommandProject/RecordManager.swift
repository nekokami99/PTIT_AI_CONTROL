//
//  RecordManager.swift
//  CommandProject
//
//  Created by Nguyễn Bách on 25/4/25.
//
import AVFoundation
import Speech
import SwiftUICore

class RecordManager: ObservableObject {
    static let shared = RecordManager()
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN"))
    private var voiceRequest: SFSpeechAudioBufferRecognitionRequest?
    private var voiceTask: SFSpeechRecognitionTask?
    private var isRecording = false
    @Published var transferText: String = ""
    
    func startRecord() {
        if voiceTask != nil {
            voiceTask?.cancel()
            voiceTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            return
        }
        
        let inputNode = audioEngine.inputNode
        
        voiceRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let voiceRequest = voiceRequest else {
            return
        }
        voiceRequest.shouldReportPartialResults = true
        
        voiceTask = speechRecognizer?.recognitionTask(with: voiceRequest, resultHandler: { [weak self] res, err in
            guard let `self` = self else { return }
            
            var isFinished = false
            
            if let res {
                let textTransfer = res.bestTranscription.formattedString
                isFinished = res.isFinal
                print(textTransfer)
                self.transferText = textTransfer
                if isFinished, !isRecording {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        Network.shared.sendStringToESP(RecordManager.shared.transferText) { _ in
                            DispatchQueue.main.async {
                                RecordManager.shared.transferText = ""
                            }
                        }
                    }
                }
            }
            
            if err != nil || isFinished {
                self.audioEngine.stop()
                self.voiceTask = nil
                self.voiceRequest = nil
                inputNode.removeTap(onBus: 0)
            }
            
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.voiceRequest?.append(buffer)
        }


        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            return
        }
    }
    
    func stopRecord() {
        audioEngine.stop()
        voiceRequest?.endAudio()
        isRecording = false
    }
    
    func checkAudioPermission(onResult: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                onResult(granted)
            }
        }
    }
    
    func checkSpeechRecognitionPermission(onResult: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            switch status {
                case .authorized:
                    onResult(true)
                case .denied, .restricted:
                    onResult(false)
                default:
                    return
            }
        }
    }
}
