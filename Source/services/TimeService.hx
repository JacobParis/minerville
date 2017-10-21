package services;

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

    public function createEvent() {
        
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
        trace("Day begins at " + Util.fint(this.time) + " after a " + Util.fint(this.start - this.stop) + " unit rest");
        UIService.instance.showCurtain("Day " + Util.fint(this.time/1000) , "(" + Util.fint((this.start - this.stop)/1000) + " DAYS HAVE PASSED)");
    }

}