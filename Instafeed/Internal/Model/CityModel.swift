//
//  CityModel.swift
//  Instafeed
//
//  Created by Eric on 2019/10/15.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import Foundation

class CityModel {
    private var name: String
    private var state: String
    private var stateId: Int
    private var latitude: Double
    private var longitude: Double
    
    init() {
        self.name = ""
        self.state = ""
        self.stateId = 0
        self.latitude = 0.0
        self.longitude = 0.0
    }
    
    init(name: String, state: String, stateId: Int, lat: Double, lng: Double) {
        self.name = name
        self.state = state
        self.stateId = stateId
        self.latitude = lat
        self.longitude = lng
    }
    
    public func getName() -> String {
        return name
    }
    
    public func getState() -> String {
        return state
    }
    
    public func getStateId() -> Int {
        return stateId
    }
    
    public func getLatitude() -> Double {
        return latitude
    }
    
    public func getLongitude() -> Double {
        return longitude
    }
}
