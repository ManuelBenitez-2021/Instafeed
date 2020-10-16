//
//  Sidemenu.swift
//  Instafeed
//
//  Created by gulam ali on 09/08/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import Foundation

struct ProfileDataModel:Decodable {
    var message:String?
    var data:Profiledata!
}

struct errorMsg : Decodable  {
    var error : String?
}

struct Profiledata:Decodable {
    var user_id:String!
    var username:String!
    var profile_url:String!
    var email:String!
    var avatar:String!
    var first_name:String!
    var middle_name:String!
    var last_name:String!
    var type:String!
    var type_name:String!
    var long:String!
    var lat:String!
    var website:String!
    var bio:String!
    var address:String!
    var pincode:String!
    var city:String!
    var bank_ifsc_code:String!
    var bank_acc_type:String!
    var bank_acc_no:String!
    var bank_name:String!
    var location_id:String!
    var updated_at:String!
    var created_at:String!
    var expired_at:String!
    var email_verified:String!
    var group_id:String!
    var status:String!
    var dt_modified:String!
    var dt_added:String!
    var phone:String!
    var sex:String!
    var birth_date:String!
    var totals:Totals!
}

struct Totals:Decodable {
//    var total_blogs:String!
    var total_news_posts:String!
    var total_followers:String!
    var total_following:String!
    var total_issues:String!
    var total_news:String!
    var total_polls:String!
}

struct RewardGift: Decodable {
    var status:Int!
    var message:String!
    var user_reward_point:String!
    var user_reward_point_used:String!
    var user_reward_point_bal:String!
    var wallet_balance:String!
    var data:[RewardGiftData]!
}
struct RewardGiftData: Decodable {
    var id:String!
    var name:String!
    var description:String!
    var image:String!
    var total_points:String!
}

