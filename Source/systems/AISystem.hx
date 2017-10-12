package systems;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.core.System;

import components.Position;
import components.Health;
import components.Ore;
import components.Task;
import components.TileImage;
import components.Worker;

import components.ai.Mining;

import nodes.AINode;
import nodes.MiningWorkerNode;
import nodes.OreWorkerNode;
import nodes.TaskWorkerNode;

import services.EntityFactory;
import services.GameDataService;
import services.TaskService;
import services.TileMapService;

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
			// Drop task if it takes longer than expected
			if(node.task.timeTaken++ > node.task.estimatedTime) {
				trace(node.entity.name + " has dropped task " + node.task.action.getName());
				trace("    Expected duration: " + node.task.estimatedTime);
				trace("    Actual time: " + node.task.timeTaken);

				// Estimate a little more time next time
				node.worker.tweakEstimations(node.task.timeTaken - node.task.estimatedTime);
				if(node.entity.has(Ore)) {
					var ore = node.entity.remove(Ore);
					var adjacentPoint = node.position.point.add(Util.anyOneOf([-1, 1]), Util.anyOneOf([-1, 1]));
					EntityFactory.instance.createOre(adjacentPoint, ore.id);
				}
				node.entity.remove(Task);	
				continue;
			}

			var destination:Point = node.task.location();
			var position:Position = node.position;
			// Travel to task
			if(Point.distance(node.position.point, destination) > 1) {
				var newX;
				var newY;
				if(Util.diff(position.x, destination.x) > Util.diff(position.y, destination.y)) {
					newX = position.x + Util.sign(destination.x - position.x);
					newY = position.y;
				} else {
					newX = position.x;
					newY = position.y +  Util.sign(destination.y - position.y);
				}		
				var collidee = EntityFactory.instance.playerAt(newX, newY);
				if(collidee == null) {
					var wall = EntityFactory.instance.blockAt(newX, newY);
					if(wall == null) {
						position.x = newX;
						position.y = newY;
					} else {
						if(wall.has(Health)) {
							mineBlock(node.entity, new Task(Skills.MINE, wall));
						}
					}
				} else {
					trace("TRADE POSITIONS!");
					//collidee.get(Position).x += 1;
					//Main.log(node.task);
					//Main.log(collidee.get(Task));
					EntityFactory.instance.tradeComponents(node.entity, collidee, Position);
					//EntityFactory.instance.tradeComponents(node.entity, collidee, Ore);

				}	
			} else {
				switch(node.task.action) {
					case MINE: mineBlock(node.entity, node.task);
					case CARRY: takeOreToBase(node.entity, node.task);
					case ATTACK: 1 + 1;
					case WALK: completeWalk(node.entity, node.task);
				}
			}
		}


		for (node in engine.getNodeList(MiningWorkerNode)) {
			var block:Entity = node.mining.block;
			var blockHealth:Health = node.mining.block.get(Health);
			blockHealth.value -= node.mining.strength;

			var blockTile:TileImage = node.mining.block.get(TileImage);
			blockTile.id = 3;

			if(blockHealth.value > 0) continue;

			node.entity.remove(Mining);
		}

		for (node in engine.getNodeList(AINode)) {
			if(node.entity.has(TileImage)) {
				var tileImage:TileImage = node.entity.get(TileImage);
				if(node.entity.has(Ore)) {
					tileImage.id = TileMapService.instance.enumMap.get(TileType.WORKER_ORE);
				} else {
					tileImage.id = TileMapService.instance.enumMap.get(TileType.WORKER);
				}
			}
		}
	}

	
	private function mineBlock(entity:Entity,task:Task) {
		entity.remove(Task);
		entity.get(Worker).train(Skills.MINE, entity.name);
		entity.add(new Mining(task.target));
	}
	private function takeOreToBase(entity:Entity,task:Task) {
		entity.remove(Task);
		var ore:Ore = task.target.remove(Ore);
		if(ore == null) Main.log(task);
		else entity.add(ore);

		var returnTask:Task = EntityFactory.instance.getWalkingToBase();
		returnTask.estimatedTime = entity.get(Worker).estimateTaskLength(returnTask, entity.get(Position).point);
		entity.add(returnTask);
		EntityFactory.instance.destroyEntity(task.target);
	}

	private function completeWalk(entity:Entity, task:Task) {
		entity.remove(Task);
		if(task.target.name == Buildings.BASE.getName()) {
			if(entity.has(Ore)) {
				entity.remove(Ore);
				var worker:Worker = entity.get(Worker);
				worker.train(Skills.CARRY, entity.name);
				// Estimate a little less time next time
				//worker.tweakEstimations(task.timeTaken - task.estimatedTime);
				GameDataService.instance.requestOre();
			}
		}
	}
}