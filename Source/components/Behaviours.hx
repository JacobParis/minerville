package components;

import ash.core.Entity;
import util.Point;

class Mining {
    public var block:Entity;
    public var strength:Int;

    public function new(block:Entity, strength:Int = 1) {
        this.block = block;
        this.strength = strength;
    }
}

class Walking {
    public var destination:Point;
    public var target:Entity;

    public function new(x:Float, y:Float, target:Entity) {
        this.destination = new Point(x, y);
        this.target = target;
    }
}