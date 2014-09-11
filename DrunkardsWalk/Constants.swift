//
//  Constants.swift
//  DrunkardsWalk
//
//  Created by Leonardo Lee on 9/10/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import Foundation

//MARK: - Notification Constants
//let kNotificationCategoryPubCrawl = "PUB_CAT"
//let kNotificationCategoryUber = "UBER_CAT"
//let kNotificationActionUber = "UBER_ID"
//let kNotificationActionCheck = "CHECK_ID"
//let kNotificationActionCancel = "CANCEL_ID"
//let kNotificationActionRateUp = "RATEUP_ID"
//let kNotificationActionRateDown = "RATEDOWN_ID"

struct kNotification {
    enum Action : String {
        case Check = "CHECK_ID"
        case Cancel = "CANCEL_ID"
        case RateUp = "RATEUP_ID"
        case RateDown = "RATEDOWN_ID"
        case CallUber = "UBER_CALL_ID"
    }
    enum Category : String {
        case PubCrawl = "PUB_CAT"
        case Uber = "UBER_CAT"
    }
    enum Remote : String {
        case JustToModify = "JUST_REMOTE_ID"
    }
}
