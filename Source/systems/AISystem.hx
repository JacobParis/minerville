package systems;

import haxe.ds.IntMap;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.core.System;

import components.Position;
import components.Health;
import components.Ore;
import components.Path;
import components.Stationary;
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

import util.Array2D;
import util.RelativeArray2D;
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

	private function lookAround(position:Point, distance:Int):RelativeArray2D<Null<Bool>> {
		var size = distance * 2 + 1;
		var surroundings:RelativeArray2D<Null<Bool>> = new RelativeArray2D<Null<Bool>>(size, size, new Point(distance,distance), false);
		for(i in 0...surroundings.size) {
			var cell = surroundings.fromIndex(i);
			var block = EntityFactory.instance.stationaryAt(position.x + cell.x - distance, position.y + cell.y - distance) != null;
			//var worker = EntityFactory.instance.stationaryAt(position.x + cell.x - 2, position.y + cell.y - 2) != null;
			surroundings.setIndex(i, block);
		}
		//trace(surroundings);
		return surroundings;
	}
	private function movePosition(position:Point, destination:Point, surroundings:RelativeArray2D<Bool>):Point {
		// If we need to move more horizontally, start there
		// Is there an obstacle where we're trying to go?
		var deltaX = Util.sign(destination.x - position.x);
		var horizontalMove:Null<Point> = null;
		if(!surroundings.getr(deltaX, 0)) {
			horizontalMove = new Point(position.x + deltaX, position.y);
		}

		var deltaY = Util.sign(destination.y - position.y);
		var verticalMove:Null<Point> = null;
		if(!surroundings.getr(0, deltaY)) {
			verticalMove = new Point(position.x, position.y + deltaY);
		}
		
		if(horizontalMove != null
		&& verticalMove != null) {
			if(Util.diff(position.x, destination.x) > Util.diff(position.y, destination.y)) {
				return horizontalMove;
			} else {
				return verticalMove;
			}
		}

		if(horizontalMove != null) return horizontalMove;

		if(verticalMove != null) return verticalMove;

		trace("Cannot move from " + position + " toward " + destination);
		return position;
	}

	private function generatePath(position:Point, destination:Point, surroundings:RelativeArray2D<Bool>):Null<Path> {
		trace(surroundings);
		var distance = Util.fint(surroundings.width / 2.0);
		// We know moving in a straight path will not work, so try strafing
		var deltaX = Util.diff(destination.x, position.x);
		var deltaY = Util.diff(destination.y, position.y);

		var targetX:Null<Int> = null;
		var targetY:Null<Int> = null;

		if(deltaX < distance && deltaY < distance) {
			targetX = destination.x - position.x + distance;
			targetY = destination.y - position.y + distance;
		} else if(deltaX > deltaY || ((deltaY == deltaX) && Util.chance(0.5))) {
			targetX = distance * Util.sign(destination.x - position.x) + distance;	
		} else {
			targetY = distance * Util.sign(destination.y - position.y) + distance;
		}

		var path = new Path();

		var closedMap:IntMap<Int> = new IntMap<Int>();
		var openMap:IntMap<Int> = new IntMap<Int>();
		openMap.set(surroundings.getCenterIndex(), null);
		var i = 500;
		while(openMap.keys().hasNext() && i-- > 0) {
			var k = openMap.keys();
			var index = k.next();
			closedMap.set(index, openMap.get(index));

			var current:Null<Point> = surroundings.fromIndex(index);
			if((current.x == targetX || targetX == null)
			&& ((current.y == targetY) || targetY == null)) {
				var segment = closedMap.get(index);
				while (closedMap.get(segment) != null) {
					surroundings.setIndex(segment, null);
					var absolutePoint = surroundings.fromIndexRelative(segment);
					var nextPoint = surroundings.fromIndexRelative(closedMap.get(segment));
					var relativePoint:Point = absolutePoint.addPoint(nextPoint.invert());
					path.add(relativePoint);
					segment = closedMap.get(segment);
				}
				trace(surroundings);
				trace(path);
				return path;
			}

			
			var neighbours = surroundings.getNeighboringIndices(index, true);
			for(i in neighbours) {
				if(!closedMap.exists(i) && !openMap.exists(i) && !surroundings.getIndex(i)) {
					openMap.set(i, index);
				}
			}

			openMap.remove(index);
		}
		return null;
		
	}

	private function moveOnPath(position:Point, path:Path) {
		var target = path.next();
		return target;
	}
	public function tock(time:Float):Void {
		for (node in engine.getNodeList(TaskWorkerNode)) {
			trace(node.entity.name + " is working...");
			Main.log(node.task);
			// Drop task if it takes longer than expected
			if(node.task.timeTaken++ > node.task.estimatedTime) {
				trace(node.entity.name + " has dropped task " + node.task.action.getName());
				trace("    Expected duration: " + node.task.estimatedTime);
				trace("    Actual time: " + node.task.timeTaken);

				// Estimate a little more time next time
				//node.worker.tweakEstimations(node.task.timeTaken - node.task.estimatedTime);
				//node.worker.detrain(node.task.action);
				if(node.entity.has(Ore)) {
					var ore = node.entity.remove(Ore);
					var adjacentPoint = node.position.point.clone().add(Util.anyOneOf([-1, 1]), Util.anyOneOf([-1, 1]));
					EntityFactory.instance.createOre(adjacentPoint, ore.id);
				}
				node.entity.remove(Task);	
				continue;
			}

			var destination:Point = node.task.location();
			var position:Position = node.position;
			// Travel to task
			if(Point.distance(position.point, destination) > 1) {
				// Remove stationary component if present
				var stationary = node.entity.get(Stationary);
				if(stationary != null) {
					node.entity.remove(Stationary);
				}

				var area = lookAround(position.point, 4);
				var target = position.point;
				if(node.entity.has(Path)) {
					
					var path = node.entity.get(Path);
					var point = path.next();
					if(point != null) {
						trace("		is moving along her path");
						target = position.point.clone().add(point.x, point.y);
					} else {
						node.entity.remove(Path);
					}
				} else {
					target = movePosition(position.point, destination, area);
				}
				
				if(target.x == position.point.x
				&& target.y == position.point.y) {
					trace("		did not move this time.");
					// We didn't move, try again
					var path = generatePath(position.point, destination, area);
					if(path != null) {
						trace(path);
						var point = path.next();
						if(point != null) {
							target = position.point.clone().add(point.x, point.y);
							node.entity.add(path);
						}
					} else {
						node.entity.remove(Task);
						continue;
						// TODO handle carried objects
					}
				}
				

				var collidee = EntityFactory.instance.workerAt(target.x, target.y);
				if(collidee != null) {
					collidee.get(Position).point = position.point;
					node.entity.add(new Stationary());
				}

				position.point = target;
			} else {
				node.entity.add(new Stationary());
				switch(node.task.action) {
					case MINE: mineBlock(node.entity, node.task);
					case CARRY: takeOreToBase(node.entity, node.task);
					case ATTACK: 1;
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
		trace("mineBlock");
		entity.remove(Task);
		entity.get(Worker).train(Skills.MINE, entity.name);
		entity.add(new Mining(task.target));
		entity.add(new Stationary());
	}
	private function takeOreToBase(entity:Entity,task:Task) {
		trace("takeOreToBase");
		entity.remove(Task);
		var ore:Ore = task.target.remove(Ore);
		if(ore == null) {
			// TODO debug
			//Main.log(task);
		} else {
			entity.add(ore);

			var returnTask:Task = EntityFactory.instance.getWalkingToBase();
			returnTask.estimatedTime = entity.get(Worker).estimateTaskLength(returnTask, entity.get(Position).point);
			entity.add(returnTask);
		}
		EntityFactory.instance.destroyEntity(task.target);
	}

	private function completeWalk(entity:Entity, task:Task) {
		trace("completeWalk");
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

typedef PathNode = {
			var x:Int;
			var y:Int;
			var index:Int;
			var parent:Null<PathNode>;
		};