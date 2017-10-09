package components.ai;

import ash.core.Entity;

import util.Point;

class Mining {
    public var position:Point;
    public var block:Entity;
    public var strength:Int;

    public function new(x:Float, y:Float, block:Entity, strength:Int = 1) {
        this.position = new Point(x, y);
        this.block = block;
        this.strength = strength;
    }

    
}