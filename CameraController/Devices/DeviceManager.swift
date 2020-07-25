//
//  DeviceManager.swift
//  CameraController
//
//  Created by Itay Brenner on 7/19/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Combine
import Foundation
import AVFoundation

class DevicesManager: ObservableObject {
    static let shared = DevicesManager()

    @Published var devices: [CaptureDevice] = []

    private init() {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown, .builtInWideAngleCamera],
                                                                mediaType: nil,
                                                                position: .unspecified)
        devices = session.devices.map({ (device) -> CaptureDevice in
            CaptureDevice(avDevice: device)
        })
    }

    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceAdded(notif:)),
                                               name: NSNotification.Name.AVCaptureDeviceWasConnected,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceRemoved(notif:)),
                                               name: NSNotification.Name.AVCaptureDeviceWasDisconnected,
                                               object: nil)
    }

    func stopMonitoring() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVCaptureDeviceWasConnected,
                                                  object: nil)
    }

    @objc func deviceAdded(notif: NSNotification) {
        guard let device = notif.object as? AVCaptureDevice else {
            return
        }

        devices.append(CaptureDevice(avDevice: device))
    }

    @objc func deviceRemoved(notif: NSNotification) {
        guard let device = notif.object as? AVCaptureDevice else {
            return
        }

        let index = devices.firstIndex { (captureDevice) -> Bool in
            captureDevice.avDevice == device
        }

        guard index != nil else {
            return
        }

        devices.remove(at: index!)
    }
}
