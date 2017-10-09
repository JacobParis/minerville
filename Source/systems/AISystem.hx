package systems;

//import openfl.display.DisplayObject;
//import openfl.display.DisplayObjectContainer;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.Position;
import components.ai.Walking;
import components.ai.Mining;
import nodes.AINode;

import util.Point;
import util.Util;

class AISystem extends System {
    private var nodes:NodeList<AINode>;

    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.nodes = engine.getNodeList(AINode);
		
	}
	
	override public function update(time:Float):Void {
		for (node in this.nodes) {
			//var component:Component = node.component;
			
		}
	}

	public function tock(time:Float):Void {
		for (node in this.nodes) {

			if(node.entity.has(Walking)) {
				var walking:Walking = node.entity.get(Walking);
				var position:Position = node.position;

				if(Point.distance(position.point, walking.destination) > 1) {
					var deltaX = Util.diff(position.x, walking.destination.x);
					var deltaY = Util.diff(position.y, walking.destination.y);
					trace(deltaX, deltaY);

					if(deltaX > deltaY) {
						position.x += Util.sign(walking.destination.x - position.x);
					} else {
						position.y += Util.sign(walking.destination.y - position.y);
					}			
				} else {
					node.entity.remove(Walking);
				}
				continue;
			}

			
		}
	}
}