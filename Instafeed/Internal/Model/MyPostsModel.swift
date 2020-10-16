//
//  MyPostsModel.swift
//  Instafeed
//
//  Created by Eric on 2019/10/16.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import Foundation

class MyPostsModel {
    private var id: Int
    private var url: String
    private var title: String
    private var date: String
    var image_360x290:String
    var video_thumb:String

    
    init(image_360x290: String = "",video_thumb: String = "") {
        self.id = 0
        self.url = ""
        self.title = ""
        self.date = ""
        self.image_360x290 = image_360x290
        self.video_thumb = video_thumb
    }
    
    init(id: Int, url: String, title: String, date: String, image_360x290: String,video_thumb: String ) {
        self.id = id
        self.url = url
        self.title = title
        self.date = date
        self.image_360x290 = image_360x290
        self.video_thumb = video_thumb

    }
    
    public func getId() -> Int {
        return id
    }
    
    public func getUrl() -> String {
        return url
    }
    
    public func getTitle() -> String {
        return title
    }
    
    public func getDate() -> String {
        return date
    }
}
