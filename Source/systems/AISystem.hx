package systems;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.core.System;

import openfl.display.Tile;

import components.Position;
import components.Health;
import components.TileImage;

import components.ai.Walking;
import components.ai.Mining;

import nodes.AINode;

import services.EntityFactory;

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
					node.entity.add(new Mining(walking.destination.x, walking.destination.y, walking.block));
					node.entity.remove(Walking);
				}
				continue;
			}

			if(node.entity.has(Mining)) {
				var mining:Mining = node.entity.get(Mining);
				var position:Position = node.position;

				if(Point.distance(position.point, mining.position) == 1) {
					var blockHealth:Health = mining.block.get(Health);
					blockHealth.value -= mining.strength;

					var blockTile:TileImage = mining.block.get(TileImage);
					blockTile.id = 3;

					if(blockHealth.value > 0) continue;
				} 

				node.entity.remove(Mining);
			}
			
		}
	}
}