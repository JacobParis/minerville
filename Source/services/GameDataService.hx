package services;

import util.Util;

/**
 *   This Service should be treated as if it were on the server
 *   and authenticated all stats and simply takes requests and 
 *   returns results if they are valid
 */
class GameDataService {
    public static var instance(default, null):GameDataService = new GameDataService();

    public var screenVisible:Bool = true;

    public var gold:Int = 0;
    public var ore:Int = 0;
    public var miners:Int = 1;
    public var usedMiners:Int = 0;

    public var bakeBatch:Int = 3;
    public var bakeTime:Int = 3;
    public var currentBake:Int = 0;
    public var bakeRate:Int = 1;

    public var time:Float = 0;
    public var stop:Float = 0;
    public var start:Float = 0;
    private var newDay:Bool = false;

    private function new() {
    }

    
    public function requestOre() {
        this.ore += Util.anyOneOf([1,1,2,3,3,4,5,7,11]);
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

    public function tock(time:Float) {
        this.time += time;

        if(!this.newDay && this.time - this.stop > 100) {
            this.newDay = true;
            endDay();
        }
    }

    public function pause() {
        this.stop = this.time;
        this.newDay = false;
    }

    public function resume() {
        if(this.newDay) {
            this.newDay = false;
            this.start = this.time;
            startDay();
        }
    }

    private function endDay() {
        trace("Day ended at " + Util.fint(this.time));
        UIService.instance.showCurtain();
    }

    private function startDay() {
        trace("Day begins at " + Util.fint(this.time) + " after a " + Util.fint(this.start - this.stop) + " unit rest");
        UIService.instance.showCurtain("Day " + Util.fint(this.time/100) , "(" + Util.fint((this.start - this.stop)/100) + " DAYS HAVE PASSED)");
    }
}