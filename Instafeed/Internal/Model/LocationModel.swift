//
//  LocationModel.swift
//  Instafeed
//
//  Created by Eric on 2019/10/15.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import Foundation

class LocationModel {
    private var name: String
    private var stateId: Int
    
    init() {
        self.name = ""
        self.stateId = 0
    }
    
    init(name: String, state: Int) {
        self.name = name
        self.stateId = state
    }
    
    public func getName() -> String {
        return name
    }
    
    public func getStateId() -> Int {
        return stateId
    }
}
