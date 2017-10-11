package systems;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.core.System;

import openfl.display.Tile;

import components.Building;
import components.Busy;
import components.Position;
import components.Health;
import components.Ore;
import components.Task;
import components.TileImage;

import components.ai.Available;
import components.ai.Walking;
import components.ai.Mining;

import nodes.AINode;
import nodes.MiningWorkerNode;
import nodes.TaskWorkerNode;

import services.EntityFactory;
import services.GameDataService;

import util.Point;
import util.Util;

class AISystem extends System {
    private var nodes:NodeList<AINode>;
	private var engine:Engine;

    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.nodes = engine.getNodeList(AINode);
		this.engine = engine;
	}
	
	override public function update(time:Float):Void {
		for (node in this.nodes) {
			//var component:Component = node.component;
			
		}
	}

	public function tock(time:Float):Void {
		for (node in engine.getNodeList(TaskWorkerNode)) {
			var destination:Point = node.task.location();
			var position:Position = node.position;
			// Travel to task
			if(Point.distance(node.position.point, destination) > 1) {
				var deltaX = Util.diff(position.x, destination.x);
				var deltaY = Util.diff(position.y, destination.y);
				trace(deltaX, deltaY);

				if(deltaX > deltaY) {
					position.x += Util.sign(destination.x - position.x);
				} else {
					position.y += Util.sign(destination.y - position.y);
				}			
			} else {
				Main.log(node.entity.components);
				switch(node.task.action) {
					case MINE: mineBlock(node.entity, node.task.target);
					case CARRY: takeOreToBase(node.entity, node.task.target);
					case ATTACK: 1 + 1;
					case WALK: completeWalk(node.entity, node.task.target);
				}
			}
		}


		for (node in engine.getNodeList(MiningWorkerNode)) {
			var position:Position = node.position;

			var blockHealth:Health = node.mining.block.get(Health);
			blockHealth.value -= node.mining.strength;

			var blockTile:TileImage = node.mining.block.get(TileImage);
			blockTile.id = 3;

			if(blockHealth.value > 0) continue;
			Main.log(node.entity.components);
			node.entity.remove(Mining);
		}
	}

	private function mineBlock(entity:Entity, blockEntity:Entity) {
		entity.remove(Task);
		entity.add(new Mining(blockEntity));
	}
	private function takeOreToBase(entity:Entity, oreEntity:Entity) {
		entity.remove(Task);
		entity.add(oreEntity.remove(Ore));
		entity.add(EntityFactory.instance.getWalkingToBase());
		EntityFactory.instance.destroyEntity(oreEntity);
	}

	private function completeWalk(entity:Entity, targetEntity:Entity) {
		entity.remove(Task);
		trace("Finished walking...");
		if(targetEntity.name == "Base") {
			trace("... to the base!");
			if(entity.has(Ore)) {
				entity.remove(Ore);
				GameDataService.instance.requestOre();
			}
		}
	}
}