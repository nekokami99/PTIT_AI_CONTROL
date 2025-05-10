//
//  ContentViewModel.swift
//  CommandProject
//
//  Created by Nguyễn Bách on 25/4/25.
//

import Foundation
import Network
import Darwin
import SystemConfiguration.CaptiveNetwork

class Network {
    static let shared = Network()
    func sendStringToESP(_ message: String, onResult: @escaping (Bool) -> Void) {
        let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: "vi-VN") // Hoặc ngôn ngữ của bạn
            formatter.numberStyle = .spellOut
        
        let newWords = message
            .lowercased()
            .removeDiacritics()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "đ", with: "d")
        
        var words = newWords.components(separatedBy: "_")
        for i in 0..<words.count {
            if let num = Int(words[i]) {
                var word = formatter.string(from: NSNumber(value: num)) ?? ""
                word = word.lowercased()
                    .removeDiacritics()
                    .replacingOccurrences(of: " ", with: "_")
                    .replacingOccurrences(of: "đ", with: "d")
                words[i] = word
            }
        }
        
        let final = words.joined(separator: "_")
        
        let espIP = "http://esp32.local/\(final)" // Thay bằng IP thật của ESP32
        var request = URLRequest(url: URL(string: espIP)!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        print(espIP)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                onResult(true)
                print("ESP Response: \(String(data: data, encoding: .utf8) ?? "")")
            } else if let error = error {
                onResult(false)
                print("Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func getNetworkSubnet() -> String? {
        var address: String?
        var netmask: String?

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                guard let interface = ptr?.pointee else { break }

                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) { // IPv4
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" { // en0 = Wi-Fi
                        // IP Address
                        if let addr = interface.ifa_addr {
                            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            getnameinfo(addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                        &hostname, socklen_t(hostname.count),
                                        nil, socklen_t(0), NI_NUMERICHOST)
                            address = String(cString: hostname)
                        }
                    }
                }

                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }

        if let ip = address {
            var components = ip.components(separatedBy: ".")
            components.removeLast()
            let subnet = components.joined(separator: ".")
            print("nxb subnet: \(subnet)")
            return subnet
        } else {
            return nil
        }
    }
}

extension String {
    func removeDiacritics() -> String {
        return self.applyingTransform(.stripDiacritics, reverse: false) ?? ""
    }
}
