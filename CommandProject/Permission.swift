//
//  Permission.swift
//  CommandProject
//
//  Created by Nguyễn Bách on 25/4/25.
//
import NetworkExtension
import CoreLocation

enum Permission {
    case location
}

class PermissionManager: NSObject {
    static let shared = PermissionManager()
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationPermission(permissionCompletion: @escaping () -> Void) {
        switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            case .denied, .restricted:
                return
            case .authorizedAlways, .authorizedWhenInUse:
                permissionCompletion()
            default:
                return
        }
    }
    
    func getCurrrentWifi(comletion: @escaping (String) -> Void) {
        requestLocationPermission {
            NEHotspotNetwork.fetchCurrent { wifi in
                print("nxb \(wifi?.ssid)")
                comletion(wifi?.ssid ?? "")
            }
        }
    }
}

extension PermissionManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
}
