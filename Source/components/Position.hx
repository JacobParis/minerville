package components;

import util.Point;

class Position {
    private var position:Point;

    public function new(x:Float, y:Float) {
        this.position = new Point(x, y);
    }

    public var x(get, set):Int;
    public var y(get, set):Int;

    private inline function get_x():Int {
        return this.position.x;
    }

    private inline function set_x(x) {
        return this.position.x = x;
    }

    private inline function get_y():Int {
        return this.position.y;
    }

    private inline function set_y(y) {
        return this.position.y = y;
    }
    
}