//
//  Home.swift
//  Instafeed
//
//  Created by gulam ali on 26/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import Foundation


//MARK:>>>>>>>>> Citizen Tab

//for recents --> top horizontal slider
struct citizenRecents:Decodable {
    var message:String
    var data:[citizenRecentsData]?
}

struct citizenRecentsData : Decodable{
    var id : String?
    var name:String?
    var description : String?
    var image:String?
}

struct adResponse: Decodable {
    var message: String
    var data: [adData]?
}

struct adData : Decodable{
    var title : String?
    var image:String?
}

struct languagess:Decodable {
    var message:String
    var data:[languagesdata]?
}

struct languagesdata : Decodable{
    var id : String?
    var name:String?
    var lang_id : String?
    var status:String?
}

struct Notificationss:Decodable {
    var message:String
    var notify_count:String
    
    var data:[NotificationData]?
}

struct NotificationData : Decodable{
    var id : String?
    var is_read:String?
    var avatar : String?
    var post_id:String?
    
    var dt_added:String?
    var notification : String?
    var module_id:String?
}


// for table feeds

struct citizenFeeds:Decodable {
    var message:String
    var data:[citizenFeedsData]?
}

struct citizenFeedsData : Decodable{
    var id : String?
    var news_category_id:String?
    var title : String?
    var slug:String?
    var short_description : String?
    var location_id:String?
    var total_likes : String?
    var total_dislikes:String?
    var total_comments : String?
    var total_views:String?
    var is_blocked:String?
    var total_flags : String?
    var dt_added:String?
    var dt_modified : String?
    var status:String?
    var user_id : String?
    var first_name:String?
    var last_name : String?
    var nickname:String?
    var avatar : String?
    var username:String?
    var image : String?
    var image_360x290 : String?
    var video_thumb : String?
    var video_360x290:String?
    var source : String?
    var latitude:String?
    var longitude : String?
    var is_anonymous:String?
    var is_editable : String?
    var is_like:String?
    var is_bookmark: String?
    var is_follow: String?
    var is_spamed: String?
//    var isExtended = false
}


//user liked the post

struct likePost:Decodable{
    var message:String
    var data:likePostdata?
}

struct likePostdata:Decodable {
    var error : String?
    var total_likes : String?
}

//user disliked the post

struct dislikePost:Decodable{
    var message:String
    var data:likePostdata?
}

struct dislikePostdata:Decodable {
    var error : String?
    var total_likes : String?
}


//user add comment

struct addcommentCITIZEN:Decodable{
    var message:String
    var data:addcommentCITIZENdata?
}
struct addcommentCITIZENdata:Decodable {
    var brand_id:String?
    var status:String?
    var comment:String?
}

// comment list

struct citizenCommentList:Decodable {
    
    var message:String
    var data:[citizenCommentListdata]?
}

struct citizenCommentListdata:Decodable {
    
    var id:String?
    var comment_id:String?
    var status:String?
    var comment:String?
    var avatar:String?
    var username:String?
    var first_name:String?
    var user_id:String?
    var thread:[citizenThredListdata]?
}

struct citizenThredListdata:Decodable {
    
    var id:String?
    var comment_id:String?
    var status:String?
    var comment:String?
    var avatar:String?
    var username:String?
    var first_name:String?
    var user_id:String?
}

// like list

struct likeList:Decodable {
    
    var message:String
    var data:[likeListdata]?
}

struct likeListdata:Decodable {
    
    var avatar_userid:String?
    var avatar:String?
    var username:String?
    var follow_status:String?
    var user_type:String?
    var like_type:String?
    var thread:[likeThredListdata]?
}

struct likeThredListdata:Decodable {
    
    var avatar_userid:String?
    var avatar:String?
    var username:String?
    var follow_status:String?
    var user_type:String?
    var like_type:String?
}




//MARK:>>>>>> Brand Tab

struct brandfeeds:Decodable{
    var message:String
    var data:[brandfeedsData]?
}

struct brandfeedsData:Decodable {
    var id : String?
    var brand_category_id:String?
    var title : String?
    var slug:String?
    
    
    var short_description : String?
    var location_id:String?
    var total_likes : String?
    var total_dislikes:String?
    
    var total_comments : String?
    var total_views:String?
    var total_flags : String?
    var dt_added:String?
    
    var dt_modified : String?
    var status:String?
    var user_id : String?
    var first_name:String?
    
    var last_name : String?
    var nickname:String?
    var avatar : String?
    var username:String?
    
    var image : String?
    var image_360x290:String?
    var video_thumb : String?
    var video_360x290:String?
    
    var source : String?
    var latitude:String?
    var longitude : String?
    var is_follow : String?
    var is_anonymous:String?
    var is_editable : String?
    var is_like:String?
    var is_bookmark:String?
    var is_spamed:String?
}


//user liked the post

struct brandlikePost:Decodable{
    var message:String
    var data:brandlikePostdata?
}

struct brandlikePostdata:Decodable {
    var error : String?
    var total_likes : String?
}

//user disliked the post

struct barnddislikePost:Decodable{
    var message:String
    var data:barnddislikePostdata?
}

struct barnddislikePostdata:Decodable {
    var error : String?
    var total_likes : String?
}

struct userBlocked:Decodable {
    var message:String?
    var data:userBlockedData?
}

struct userBlockedData:Decodable{
    var username:String?
    var message:String?
}


//user add comment

struct addcommentBRAND:Decodable{
    var message:String
    var data:addcommentBRANDdata?
}
struct addcommentBRANDdata:Decodable {
    var brand_id:String?
    var status:String?
    var comment:String?
}

// comment list

struct brandCommentList:Decodable {
    var message:String
    var data:[brandCommentListdata]?
}
struct brandCommentListdata:Decodable {
    var id:String?
    var comment_id:String?
    var status:String?
    var comment:String?
    var avatar:String?
    var username:String?
    var first_name:String?
}


//brand title tap

struct brandTitletap:Decodable {
    var message:String
    var data:[brandTitletapdata]?
}
struct brandTitletapdata:Decodable {
    var id:String?
    var name:String?
}


struct SellFeed:Decodable{
    var message:String
//    var data:[SellfeedsData]?
    var data:[citizenFeedsData]?
}

struct SellfeedsData:Decodable {
    var id : String?
    var news_category_id:String?
    var title : String?
    var slug:String?
    
    
    var short_description : String?
    var location_id:String?
    var total_likes : String?
    var total_dislikes:String?
    
    var total_comments : String?
    var total_views:String?
    var total_flags : String?
    var dt_added:String?
    
    var dt_modified : String?
    var status:String?
    var user_id : String?
    var first_name:String?
    
    var last_name : String?
    var nickname:String?
    var avatar : String?
    var username:String?
    
    var image : String?
    var image_360x290:String?
    var video : String?
    var video_thumb : String?
    var video_360x290:String?
    
    var source : String?
    var latitude:String?
    var longitude : String?
    var is_follow : String?
    var is_anonymous:String?
    var is_editable : String?
    var is_like:String?
    var is_bookmark:String?
    var is_spamed:String?
}

