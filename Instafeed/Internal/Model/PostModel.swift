//
//  PostModel.swift
//  Instafeed
//
//  Created by eric on 2019/9/26.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import Foundation

class PostModel {
    private var url: String
    private var name: String
    private var postId: String
    var image_360x290: String
    var video_thumb: String

    
    init(image_360x290:String = "", video_thumb:String = "") {
        self.url = ""
        self.name = ""
        self.postId = ""
        self.image_360x290 = image_360x290
        self.video_thumb = video_thumb

    }
    
    init(url: String, name: String, postId: String,image_360x290:String = "", video_thumb:String = "") {
        self.url = url
        self.name = name
        self.postId = postId
        self.image_360x290 = image_360x290
        self.video_thumb = video_thumb

    }
    
    public func getUrl() -> String {
        return url
    }
    
    public func getName() -> String {
        return name
    }
    
    public func getID() -> String {
        return postId
    }
}

