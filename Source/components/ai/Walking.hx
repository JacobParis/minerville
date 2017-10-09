package components.ai;

import ash.core.Entity;
import util.Point;

class Walking {
    public var destination:Point;
    public var block:Entity;

    public function new(x:Float, y:Float, block:Entity) {
        this.destination = new Point(x, y);
        this.block = block;
    }

    
}