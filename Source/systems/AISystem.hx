package systems;

import haxe.ds.IntMap;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.core.System;

import components.TilePosition;
import components.Health;
import components.Marker;
import components.Ore;
import components.Path;
import components.Stationary;
import components.Task;
import components.TileImage;

import components.Worker;

import components.ai.Mining;

import nodes.WorkerNode;
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
    private var nodes:NodeList<WorkerNode>;
	private var engine:Engine;
	private var map:TileMapService;
	private var factory:EntityFactory;

    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.nodes = engine.getNodeList(WorkerNode);
		this.engine = engine;
		this.map = TileMapService.instance;
		this.factory = EntityFactory.instance;

	}

	private function movePosition(position:Point, destination:Point, surroundings:RelativeArray2D<Bool>, debug:Bool = false):Point {
		var deltaX = Util.sign(destination.x - position.x);
		var deltaY = Util.sign(destination.y - position.y);
		
		var horizontalMove:Null<Point> = new Point(position.x + deltaX, position.y);
		var verticalMove:Null<Point> = new Point(position.x, position.y + deltaY);
		
		if(surroundings.getr(deltaX, 0)) {
			factory.addStimulus(horizontalMove, 1.1);
			horizontalMove = null;
		}

		if(surroundings.getr(0, deltaY)) {
			factory.addStimulus(verticalMove, 1.1);
			verticalMove = null;
		}
		
		if(horizontalMove != null && verticalMove != null) {
			if(Util.diff(position.x, destination.x) > Util.diff(position.y, destination.y)) {
				return horizontalMove;
			} else {
				return verticalMove;
			}
		}

		if(horizontalMove != null) return horizontalMove;

		if(verticalMove != null) return verticalMove;

		if(debug) trace("Cannot move from " + position + " toward " + destination);
		return position;
	}

	private function generatePath(position:Point, destination:Point, surroundings:RelativeArray2D<Bool>, debug:Bool = false):Null<Path> {
		var distance = Util.fint(surroundings.width / 2.0);

		var deltaX = Util.diff(destination.x, position.x);
		var deltaY = Util.diff(destination.y, position.y);

		var targetX:Null<Int> = null;
		var targetY:Null<Int> = null;

		if(distance > deltaX && distance > deltaY) {
			targetX = destination.x - position.x + distance;
			targetY = destination.y - position.y + distance;
		} else if(deltaX > deltaY || ((deltaY == deltaX) && Util.chance(0.5))) {
			targetX = distance * Util.sign(destination.x - position.x) + distance;	
		} else {
			targetY = distance * Util.sign(destination.y - position.y) + distance;
		}

		var path = new Path(position);

		var closedList:List<PathNode> = new List<PathNode>();
		var openList:List<PathNode> = new List<PathNode>();

		// Add the worker's location to the list	
		openList.push({index: surroundings.getCenterIndex(), parent: null});

		while(openList.length > 0) {
			var current = openList.pop();

			closedList.add(current);
			
			var neighbours = surroundings.getNeighboringIndices(current.index, true);
			for(i in neighbours) {
				if((function () {
					for(closed in closedList) {
						if(closed.index == i) return true;
					}

					return false;
				})()) continue;

				if((function () {
					for(open in openList) {
						if(open.index == i) return true;
					}

					return false;
				})()) continue;
				
				var point = surroundings.fromIndex(i);
				if((point.x == targetX || targetX == null)
				&& (point.y == targetY || targetY == null)) {
					
					var parent = current;
					while (parent != null) {
						surroundings.setIndex(parent.index, null);
						
						var absolutePoint = surroundings.fromIndexRelative(parent.index);

						path.add(absolutePoint);
						parent = parent.parent;
					}
					
					return path;
				}

				if(surroundings.getIndex(i)) continue;

				openList.add({
					index: i,
					parent: current
				});
			}

		}

		return null;
	}

	private function moveOnPath(position:Point, path:Path) {
		var target = path.next();
		return target;
	}

	private function dropTask(entity:Entity, task:Task) {
		//trace(entity.name + " has dropped task " + task.action.getName());
		//trace("    Expected duration: " + task.estimatedTime);
		//trace("    Actual time: " + task.timeTaken);

		// Estimate a little more time next time
		if(entity.has(Worker)) {
			entity.get(Worker).tweakEstimations(task.timeTaken - task.estimatedTime);
		}
		//node.worker.detrain(node.task.action);
		if(entity.has(Ore)) {
			var ore = entity.remove(Ore);
			if(entity.has(TilePosition)) {
				// TODO check for surroundings
				//var adjacentPoint = entity.get(Position).point.clone().add(Util.anyOneOf([-1, 0, 1]), Util.anyOneOf([-1, 1]));
				//factory.createOre(adjacentPoint, ore.id);
			}
		}
		entity.remove(Task);	
	}
	public function tock(time:Float):Void {
		
		for (node in engine.getNodeList(TaskWorkerNode)) {
			var debug = node.entity.has(Marker);
			
			// Drop task if it takes longer than expected
			if(node.task.timeTaken++ > node.task.estimatedTime) {
				
				dropTask(node.entity, node.task);
				continue;
			}

			var destination:Point = node.task.location();
			var position:TilePosition = node.position;
			// Travel to task
			if(Point.distance(position.point, destination) > 1) {
				
				// Remove stationary component if present
				// Marked Entities should always be stationary
				// This stops other workers from bumping them out of the way
				if(node.entity.has(Stationary) && !node.entity.has(Marker)) {
					node.entity.remove(Stationary);
				}

				var area = map.lookAround(position.point, 6);
				var target = position.point.clone();

				if(node.entity.has(Path)) {
					var path:Path = node.entity.get(Path);
					var point = path.next();
					if(point == null) {
						node.entity.remove(Path);
					} else {
						target = path.origin.clone().addPoint(point);
					}
				} else {
					target = movePosition(position.point, destination, area);
				
					if(target.x == position.point.x
					&& target.y == position.point.y) {
						if(debug) {
							trace(node.entity.name + " did not move. Generating path...");
						}
						//trace("		did not move this time.");
						// We didn't move, try again'
						var path = generatePath(position.point, destination, area, debug);
						if(path == null) {
							dropTask(node.entity, node.task);
							continue;
						} else {
							node.entity.add(path);
						}
					}
				}
				
				// If the worker collides with another worker, swap their positions
				var collidee = factory.workerAt(target.x, target.y);
				if(collidee != null) {
					collidee.get(TilePosition).point = position.point;
					node.entity.add(new Stationary());
				}

				// The target position is safe, move there
				position.point = target;
			} else {
				// We have arrived at our destination
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
			var blockHealth:Health = node.mining.block.get(Health);
			blockHealth.value -= node.mining.strength;

			// TODO delegate to animation system
			var blockTile:TileImage = node.mining.block.get(TileImage);
			blockTile.id = 3;

			if(blockHealth.value > 0) continue;

			node.entity.remove(Mining);
		}

		// TODO move to different system
		for (node in engine.getNodeList(WorkerNode)) {
			if(!node.entity.has(TileImage)) continue;

			var tileImage:TileImage = node.entity.get(TileImage);
			if(node.entity.has(Ore)) {
				tileImage.id = map.enumMap.get(TileType.WORKER_ORE);
			} else {
				tileImage.id = map.enumMap.get(TileType.WORKER);
			}
		}
	}

	
	private function mineBlock(entity:Entity,task:Task) {
		//trace("mineBlock");
		entity.remove(Task);
		entity.get(Worker).train(Skills.MINE, entity.name);
		entity.add(new Mining(task.target));
		entity.add(new Stationary());
	}
	private function takeOreToBase(entity:Entity,task:Task) {
		//trace("takeOreToBase");
		entity.remove(Task);

		if(task.target.has(Ore)) {
			var ore:Ore = task.target.remove(Ore);

			entity.add(ore);

			var returnTask:Task = factory.getWalkingToBase();
			returnTask.estimatedTime = entity.get(Worker).estimateTaskLength(returnTask, entity.get(TilePosition).point);
			entity.add(returnTask);
		}

		factory.destroyEntity(task.target);
	}

	private function completeWalk(entity:Entity, task:Task) {
		//trace("completeWalk");
		if(task.target.name == Buildings.BASE.getName()) {
			if(entity.has(Ore)) {
				entity.remove(Ore);
				var worker:Worker = entity.get(Worker);
				worker.train(Skills.CARRY, entity.name);
				// Estimate a little less time next time
				worker.tweakEstimations(task.timeTaken - task.estimatedTime);
				GameDataService.instance.requestOre();
			} else {
				trace("Worker did not have Ore");
			}
		}
		entity.remove(Task);
	}
}

typedef PathNode = {
	var index:Int;
	var parent:Null<PathNode>;
};