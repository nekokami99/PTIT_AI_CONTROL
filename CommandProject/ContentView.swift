//
//  ContentView.swift
//  CommandProject
//
//  Created by Nguyễn Bách on 25/4/25.
//

import SwiftUI

// MARK: cần entitlement access wifi infomation
struct WifiView: View {
    @State private var isShowToast: Bool = false
    @State private var wifiName: String = ""
    @StateObject private var voiceManager = RecordManager.shared
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 100)
            Image(uiImage: UIImage(named: "Logo")!)
                .resizable()
                .frame(width: 200, height: 200)
            ResultTextView(transferText: $voiceManager.transferText, isShowToast: $isShowToast)
            RecordButton()
            Spacer()
                .frame(height: 30)
            Text("PTIT AI CONTROL")
                .font(.system(size: 25))
                .fontWeight(.medium)
                .foregroundColor(.red)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        .onAppear {
            PermissionManager.shared.getCurrrentWifi { wifiName in
                print("wifi name: \(wifiName)")
                self.wifiName = wifiName
            }
            
            voiceManager.checkAudioPermission { isGranted in
                //
            }
            
            voiceManager.checkSpeechRecognitionPermission { isGranted in
                //
            }
        }
    }
}

struct ResultTextView: View {
    @Binding var transferText: String
    @Binding var isShowToast: Bool
    var body: some View {
        HStack {
            if transferText.isEmpty {
                Text("Đang chờ lệnh ...")
                    .foregroundColor(.black)
            } else {
                Text(transferText)
                    .foregroundColor(.black)
            }
        }
    }
}

struct RecordButton: View {
    let recordingText = Text(RecordManager.shared.transferText)
        .foregroundColor(.black)
    @State private var isLongPress = false
    var body: some View {
        VStack {
            Image(systemName: "mic.circle.fill")
                .resizable()
                .frame(width: 70, height: 70)
                .contentShape(Rectangle())
                .foregroundColor(isLongPress ? .red : .blue)
                .onLongPressGesture(minimumDuration: 0.2, perform: {
                    //
                }, onPressingChanged: { isPress in
                    isLongPress = isPress
                    if isPress {
                        RecordManager.shared.startRecord()
                    } else {
                        RecordManager.shared.stopRecord()
                    }
                })
                .padding(.top, 40)
        }
    }
}

struct PasswordInputView: View {
    @State private var password: String = ""
    @State private var isReveal = false
    var body: some View {
        HStack {
            if isReveal {
                TextField("Password", text: $password)
                    .frame(height: 40)
                    .padding(.leading, 20)
            } else {
                SecureField("Password", text: $password)
                    .frame(height: 40)
                    .padding(.leading, 20)
            }
            Image(systemName: isReveal ? "eye.slash" : "eye")
                .padding(.trailing, 10)
                .onTapGesture {
                    isReveal.toggle()
                }
        }
        .border(Color.gray)
    }
}

struct WifiInputView: View {
    @Binding var wifiName: String
    var body: some View {
        HStack {
            Text("Tên wifi: \(wifiName)")
                .frame(height: 40)
                .padding(.leading, 20)
                .foregroundColor(.black)
            Button("Đổi wifi") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
            }
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    WifiView()
}
