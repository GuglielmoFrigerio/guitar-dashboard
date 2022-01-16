//
//  MidiFactory.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 22/12/21.
//

import Foundation
import CoreMIDI
import os
import UIKit

extension MIDINotificationMessageID {
    var name: String {
        get {
            switch (self) {
            case .msgIOError:
                return "IO Error"
                
            case .msgObjectAdded:
                return "Object Added"
                
            case .msgObjectRemoved:
                return "Object Removed"
                
            case .msgPropertyChanged:
                return "Property Changed"
                
            case .msgSetupChanged:
                return "Setup Changed"
                
            case .msgSerialPortOwnerChanged:
                return "Serial Port Owner Changed"
                
            case .msgThruConnectionsChanged:
                return "Thru Connections Changed"
                
            @unknown default:
                return "Unknown Message"
            }
            
        }
    }
}

extension MIDIObjectRef {
    
    func getName() -> String {
        return getStringProperty(propertyId: kMIDIPropertyName)
    }
    
    func getDisplayName() -> String {
        return getStringProperty(propertyId: kMIDIPropertyDisplayName)
    }
    
    func getStringProperty(propertyId: CFString) -> String {
        var property : Unmanaged<CFString>?
        let err = MIDIObjectGetStringProperty(self, propertyId, &property)
        if err == noErr {
            return property!.takeRetainedValue() as String
        }
        return ""
    }
}

public class MidiFactory: MidiFactoryProtocol {
    var midiClientRef: MIDIClientRef
    let logger: Logger
    var setupChangedHandler: ((MidiFactory) -> Void)? = nil
    
    private func dumpDevices() {
        let count = MIDIGetNumberOfDevices()
        (0 ..< count).forEach { index in
            let midiDevice = MIDIGetDevice(index)
            let name = midiDevice.getName()
            logger.log("Device: \(name)")
            dumpDeviceEntities(deviceRef: midiDevice, name: name)
        }
    }
    
    private func dumpExternalDevices() {
        let count = MIDIGetNumberOfExternalDevices()
        (0 ..< count).forEach { index in
            let midiDevice = MIDIGetExternalDevice(index)
            let name = midiDevice.getName()
            logger.log("External Device: \(name)")
        }
    }
    
    private func dumpDeviceEntities(deviceRef: MIDIDeviceRef, name: String) {
        (0 ..< MIDIDeviceGetNumberOfEntities(deviceRef)).forEach {
            index in
            let entity = MIDIDeviceGetEntity(deviceRef, index)
            let entityName = entity.getName()
            logger.log("Device: \(name) entity: \(entityName)")
            dumpEntity(entityRef: entity, deviceName: name, entityName: entityName)
        }
    }
    
    private func dumpEntity(entityRef: MIDIEntityRef, deviceName: String, entityName: String) {
        (0 ..< MIDIEntityGetNumberOfSources(entityRef)).forEach {
            index in
            let sourceRef = MIDIEntityGetSource(entityRef, index)
            let sourceName = sourceRef.getName()
            logger.log("Device: \(deviceName) entity: \(entityName), source: \(sourceName)")
        }
        
        (0 ..< MIDIEntityGetNumberOfDestinations(entityRef)).forEach {
            index in
            let destinationRef = MIDIEntityGetDestination(entityRef, index)
            let destinationName = destinationRef.getName()
            logger.log("Device: \(deviceName) entity: \(entityName), destination: \(destinationName)")
        }
    }
    
    private func getSourceIndex(deviceName: String) -> Int {
        let numberOfSources = MIDIGetNumberOfSources()
        
        for idx in 0...numberOfSources {
            let midiEndpointRef = MIDIGetSource(idx)
            var property : Unmanaged<CFString>?
            let err = MIDIObjectGetStringProperty(midiEndpointRef, kMIDIPropertyDisplayName, &property)
            if err == noErr {
                let displayName = property!.takeRetainedValue() as String
                if displayName == deviceName {
                    return idx
                }
            }
        }
        return -1;
    }
    
    private func getDestinationIndex(deviceName: String) -> Int {
        let numberOfDestionations = MIDIGetNumberOfDestinations()
        for idx in 0...numberOfDestionations {
            let midiEndpointRef = MIDIGetDestination(idx)
            var property : Unmanaged<CFString>?
            let err = MIDIObjectGetStringProperty(midiEndpointRef, kMIDIPropertyDisplayName, &property)
            if err == noErr {
                let displayName = property!.takeRetainedValue() as String
                if displayName == deviceName {
                    return idx
                }
            }
        }
        return -1;
    }

    init?(clientName: String) {
        logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MidiFactory")
        
        midiClientRef = MIDIClientRef()
        let status = MIDIClientCreateWithBlock(clientName as CFString, &midiClientRef) {
            [weak self]
            midiNotification in
            
            let midiNotification: MIDINotification = midiNotification.pointee
            self!.logger.log("Message received. id: \(midiNotification.messageID.name) size: \(midiNotification.messageSize)")
            
            if midiNotification.messageID == .msgSetupChanged {
                self?.setupChangedHandler?(self!)
            }
            
        }

        if (status != noErr) {
            logger.warning("MIDIClientCreateWithBlock failed: \(status)")
            return nil
        }

        dumpDevices()
        dumpExternalDevices()
    }
    
    func createInputPort(deviceName: String) -> MidiInputPort? {
        let sourceIndex = getSourceIndex(deviceName: deviceName)
        if sourceIndex != -1 {
            return try? MidiInputPort(midiClientRef: midiClientRef, portName: deviceName, sourceIndex: sourceIndex)
        }
        return nil
    }
    
    func createInputPort(sourceIndex: Int, portName: String) -> MidiInputPort? {
        return try? MidiInputPort(midiClientRef: midiClientRef, portName: portName, sourceIndex: sourceIndex)
    }
    
    func createOutputPort(deviceName: String) -> MidiOutputPort? {
        let destinationIndex = getDestinationIndex(deviceName: deviceName)
        if destinationIndex != -1 {
            return try? MidiOutputPort(midiClientRef: midiClientRef, portName: deviceName, destinationIndex: destinationIndex)
        }
        return nil
    }
    
    func createOutputPort(destinationIndex: Int, portName: String) -> MidiOutputPort? {
        return try? MidiOutputPort(midiClientRef: midiClientRef, portName: portName, destinationIndex: destinationIndex)
    }
    
    func getMidiSources() -> [String] {
        
        var midiSources = [String]()
        
        let numberOfSources = MIDIGetNumberOfSources()
        
        for idx in 0...numberOfSources {
            let midiEndpointRef = MIDIGetSource(idx)
            let displayName = midiEndpointRef.getDisplayName()
            midiSources.append(displayName)
        }
        
        return midiSources

    }
    
    func getMidiDestinations() -> [String] {
        var midiDestinations = [String]()
        
        let numberOfDestinations = MIDIGetNumberOfDestinations()
        
        for idx in 0...numberOfDestinations {
            let midiEndpointRef = MIDIGetDestination(idx)
            let displayName = midiEndpointRef.getDisplayName()
            midiDestinations.append(displayName)
        }
        
        return midiDestinations

    }
    
    func logMidiEndpoints() {
        for source in getMidiSources() {
            self.logger.log("source: \(source)")
        }
        
        for destination in getMidiDestinations() {
            self.logger.log("destination: \(destination)")
        }
    }
        
    func onSetupChanged(handler: @escaping (MidiFactory) -> Void) {
        self.setupChangedHandler = handler
    }
}
