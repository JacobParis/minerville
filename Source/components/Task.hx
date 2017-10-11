package components;

import ash.core.Entity;

import services.TaskService;

import util.Point;
import util.ds.Prioritizable;

class Task implements Prioritizable {
    public var target:Entity;
    public var action:Skills;
    public var difficulty:Float = 1;

    public var bidders:Array<Entity>;
    public var timePosted:Float;
    public var priority(default, null):Float;
	public var position(default, null):Int;

    public function new(action:Skills, target:Entity) {
        this.action = action;
        this.target = target;
    }

    public inline function location():Point {
        return target.get(Position).point;
    }
}