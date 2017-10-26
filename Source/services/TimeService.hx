package services;

import components.GameEvent;
import components.TilePosition;

import enums.EventTypes;

import util.Util;

class TimeService {
    public static var instance(default, null):TimeService = new TimeService();


    public var time:Float = 0;
    public var stop:Float = 0;
    public var start:Float = 0;
    private var newDay:Bool = false;

    private function new() {}
    
    public function initialize():TimeService {

        return this;
    }
	
	public function update(time:Float):Void {
	
	}

    

    public function tock(time:Float) {
        this.time += time;

        if(!this.newDay && this.time - this.stop > 1000) {
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
        var delta = Math.ceil((this.start - this.stop)/10000);
        trace("Day begins at " + Util.fint(this.time) + " after a " + Util.fint(this.start - this.stop) + " unit rest");
        UIService.instance.showCurtain("Day " + Math.ceil(this.time/10000) , "(" + delta + " DAYS HAVE PASSED)");

        var gold = 0;

        for(i in 0...delta) {
            if(Util.chance(0.9)) continue;
            else if(Util.chance(0.9)) { gold += Util.anyOneOf([1,2,3,4,5]);}
            else if(Util.chance(0.9)) { gold += Util.anyOneOf([11,12,13,14,15]);}
            else if(Util.chance(0.9)) { gold += Util.anyOneOf([10,20,30,40,50]);}
            else if(Util.chance(0.1)) { gold += Util.anyOneOf([100,200,300,400,500]);}

            if(Util.chance(0.08)) {
                var block = EntityFactory.instance.findBlock();
                if(block != null) {
                    TileMapService.instance.destroyBlock(block);
                }
            }
            
            // Cave-in
            if(Util.chance(0.01) && Util.chance(0.01)) {
                var block = EntityFactory.instance.findBlock();
                var cavein = "
				-X-
				XXX
				-X-";

                var position = block.get(TilePosition);

                TileMapService.instance.loadTilePattern(cavein, position.point.clone().add(-1,-1), true);

                var event = new GameEvent(EventTypes.DISASTER, "Cave-In at " + position.point);
                NotificationService.instance.addNotification(event);
            }
        }

        for(i in 0...delta) {
            var ore = EntityFactory.instance.findOre();
            if(ore != null) {
                EntityFactory.instance.destroyEntity(ore);
                gold += Util.anyOneOf([1,2,3,4,5]);
            }
        }

        GameDataService.instance.gold += gold;
        if(gold > 100) NotificationService.instance.addNotification(new GameEvent(EventTypes.LOOT, cast gold));
    }

}