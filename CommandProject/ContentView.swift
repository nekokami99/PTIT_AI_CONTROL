//
//  ContentView.swift
//  CommandProject
//
//  Created by Nguyễn Bách on 25/4/25.
//

import SwiftUI

// MARK: cần entitlement access wifi infomation
struct WifiView: View {
    @Environment(\.sizeCategory) var typeSize
    @State private var isShowToast: Bool = false
    @State private var wifiName: String = ""
    @StateObject private var voiceManager = RecordManager.shared
    @State private var ip: String = ""
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 100)
            Image(uiImage: UIImage(named: "Logo")!)
                .resizable()
                .frame(width: 200, height: 200)
            TextField("Nhập ip của thiết bị", text: $ip)
                .frame(width: 300, height: 40)
                .background(Color.white)
                .cornerRadius(20)
                .textFieldStyle(.roundedBorder)
            ResultTextView(transferText: $voiceManager.transferText)
            RecordButton(ip: $ip)
            Spacer()
                .frame(height: 30)
            Text("PTIT AI CONTROL")
                .fontWeight(.medium)
                .foregroundColor(.red)
                .minimumScaleFactor(0.5)
                .font(typeSize == .accessibilityExtraExtraExtraLarge ? .system(size: 25) : .system(size: 25))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        .onAppear {
            Network.shared.sendStringToESP(ip: "", message: "") { _ in
                //
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
    @Environment(\.sizeCategory) var typeSize
    @Binding var transferText: String
    var body: some View {
        VStack {
            if transferText.isEmpty {
                Text("Đang chờ lệnh ...")
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.5)
                    .font(typeSize == .accessibilityExtraExtraExtraLarge ? .system(size: 20) : .system(size: 20))
            } else {
                Text(transferText)
                    .foregroundColor(.black)
            }
        }
    }
}

struct RecordButton: View {
    @State private var isLongPress = false
    @Binding var ip: String
    var body: some View {
        VStack {
            Image(systemName: "mic.circle.fill")
                .resizable()
                .frame(width: 70, height: 70)
                .contentShape(Rectangle())
                .foregroundColor(isLongPress ? .red : .blue)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            if !isLongPress {
                                RecordManager.shared.startRecord()
                                isLongPress = true
                            }
                        })
                        .onEnded({ value in
                            print("nxb end")
                            RecordManager.shared.stopRecord()
                            isLongPress = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                if RecordManager.shared.transferText.isEmpty { return }
                                Network.shared.sendStringToESP(ip: ip, message: RecordManager.shared.transferText) { _ in
                                    DispatchQueue.main.async {
                                        RecordManager.shared.transferText = ""
                                    }
                                }
                            }
                        })
                    , isEnabled: true)
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
