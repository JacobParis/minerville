package components;

import util.Point;

class Position {
    public var point:Point;

    public function new(x:Float, y:Float) {
        this.point = new Point(x, y);
    }

    public var x(get, set):Int;
    public var y(get, set):Int;

    private inline function get_x():Int {
        return this.point.x;
    }

    private inline function set_x(x) {
        return this.point.x = x;
    }

    private inline function get_y():Int {
        return this.point.y;
    }

    private inline function set_y(y) {
        return this.point.y = y;
    }
    
}