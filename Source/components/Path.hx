package components;

import util.Point;
import util.ds.ArrayedStack;

class Path {

    public var points:ArrayedStack<Point>;
    public var origin:Point;

    public function new(origin:Point) {
        this.points = new ArrayedStack<Point>();
        this.origin = origin;
    }

    public function next():Null<Point> {
        return (this.points.size > 0) ? this.points.pop() : null;
    }

    public function add(point:Point) {
        this.points.push(point);
    }
}