//
//  AppID.swift
//  GameFace2.0
//
//  Created by Eric.Fox on 3/24/18.
//  Copyright © 2018 GameFace, LLC. All rights reserved.
//

import GoogleMobileAds

public struct AppConst {
    
    
    /// This number is responsible:
    /// How many points  needed to win or throw the draw (host && slave >= pointsToWin)
    static let pointsToWin: Int = 3
    
    /**
     AgoraAppID
        App ID issued to the application developers by Agora. Apply for a new one from Agora if the key is missing in your kit. Each project is assigned a unique App ID. The App ID identifies your project and organization in the [joinChannelByToken](joinChannelByToken:channelId:info:uid:joinSuccess:) method to access the Agora Global Network, and enable one-to-one or one-to-more communication or live-broadcast sessions using a unique channel name for your App ID.
     */
    static let AgoraAppID: String =  "4b9acf5d3eab42e9803bfaca76378341"
    
    /**
     matchResultAdUnitID
         Required value created on the AdMob website. Create a new ad unit for every unique placement of an ad in your application. Set this to the ID assigned for this placement. Ad units are important for targeting and statistics.
         
     
     
         Current AdMob ad unit ID: @"ca-app-pub-9681215584101444/7405167324" - from adMob Dashboard
         Test  AdMob ad unit ID: @"ca-app-pub-3940256099942544/2934735716" - only for testing
     */
    static let matchResultAdUnitID: String = "ca-app-pub-9681215584101444/7405167324"
    /// Typically 300x250.
    static let adSize: GADAdSize = kGADAdSizeMediumRectangle // kGADAdSizeMediumRectangle
    
    
    
    //MARK: - appsFlyer Dev Key
    static let flyerDevKey = "vxZ7rWvonVJfwyXSW5dYUW"
    static let flyerAppId = "id1462710737"

}
