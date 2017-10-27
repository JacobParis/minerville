package services;

import components.GameEvent;

import enums.Types;

import util.Util;

/**
 *   This Service should be treated as if it were on the server
 *   and authenticated all stats and simply takes requests and 
 *   returns results if they are valid
 */
class GameDataService {
    public static var instance(default, null):GameDataService = new GameDataService();

    public var screenVisible:Bool = true;

    public var gold:Int = 100000;
    public var ore:Int = 0;
    public var miners:Int = 1;
    public var usedMiners:Int = 0;

    public var bakeBatch:Int = 3;
    public var bakeTime:Int = 3;
    public var currentBake:Int = 0;
    public var bakeRate:Int = 1;

    private function new() {
    }

    
    public function requestOre() {
        if(Util.chance(0.9)) { gold += Util.anyOneOf([1,2,3,4,5]);}
        else if(Util.chance(0.9)) { gold += Util.anyOneOf([11,12,13,14,15]);}
        else if(Util.chance(0.9)) { gold += Util.anyOneOf([10,20,30,40,50]);}
        else if(Util.chance(0.1)) { 
            var loot =  Util.anyOneOf([100,200,300,400,500]);
            this.gold += loot;
            NotificationService.instance.addNotification(new GameEvent(EventTypes.LOOT, cast loot));
        }

        trace("Gold: " + this.gold);
    }

    public function buyMiner() {
        if(this.gold > 100) {
            this.gold -= 100;
            miners++;
        }
    }

    public function useMiner() {
        this.usedMiners += 1;
        this.miners -= 1;
    }

    public function restoreMiner() {
        this.miners += 1;
        this.usedMiners -= 1;
    }

    public function buyRefinery() {
        if(this.gold > 300) {
            this.gold -= 280;
            this.ore -= 10;

            this.bakeRate += 1;
            this.bakeBatch += 1;
        }
    }

    
}