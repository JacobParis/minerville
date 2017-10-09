package components.ai;

import ash.core.Entity;
import util.Point;

class Walking {
    public var destination:Point;
    public var target:Entity;

    public function new(x:Float, y:Float, target:Entity) {
        this.destination = new Point(x, y);
        this.target = target;
    }

    
}