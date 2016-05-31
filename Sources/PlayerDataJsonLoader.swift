//
//  PlayerDataJsonLoader.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/30/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import ObjectMapper

struct PlayerDataJsonLoader {
    
    let playerData: PlayerData
    
    init(jsonData: NSData) {
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        self.init(jsonString: jsonString)
    }
    
    init(jsonString: String) {
        let gameDataFileName = NSBundle.mainBundle().objectForInfoDictionaryKey("GameDataFileName") as! String
        let overallLeaderboardIDKey = "overall_leaderboard_id"
        let levelsKey = "levels"
        
        var playerData = Mapper<PlayerData>().map(jsonString)!
        
        // Fill player data with game data.
        let gameData = NSData(contentsOfFile: gameDataFileName.pathInResourcesBundle())!
        let gameDataJSON = try! NSJSONSerialization.JSONObjectWithData(gameData, options: .AllowFragments) as! [String : AnyObject]
        
        playerData.overallLeaderboardID = gameDataJSON[overallLeaderboardIDKey] as! String
        
        let levelsJSON = gameDataJSON[levelsKey]
        let levels = Mapper<Level>().mapArray(levelsJSON)!
        for (index, progress) in playerData.levelProgressItems.enumerate() {
            for level in levels where level.identifier == progress.levelID {
                playerData.levelProgressItems[index].level = level
                break
            }
        }
        
        self.playerData = playerData
    }
}
