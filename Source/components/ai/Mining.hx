package components.ai;

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