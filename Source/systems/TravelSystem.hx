package systems;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.Behaviours;
import components.Markers;
import components.TilePosition;
import components.Path;

import services.EntityFactory;
import services.TileMapService;

import nodes.TravelNode;

import util.RelativeArray2D;
import util.Point;
import util.Util;

class TravelSystem extends System {
	private var engine:Engine;
	private var factory:EntityFactory;
	private var map:TileMapService;

    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		this.factory = EntityFactory.instance;
		this.map = TileMapService.instance;
		
	}
	
	public function tock(_):Void {
		for (node in engine.getNodeList(TravelNode)) {
			var isSelected = node.entity.has(Marker);

			var destination:Point = node.walking.destination;
			var position:TilePosition = node.position;
			// Travel to task
			if(Point.distance(position.point, destination) <= 1) {
				node.entity.remove(Walking);
				continue;
			}
			
			// Remove stationary component if present
			// Marked Entities should always be stationary
			// This stops other workers from bumping them out of the way
			if(node.entity.has(StationaryMarker) && !isSelected) {
				node.entity.remove(StationaryMarker);
			}

			var vision = isSelected ? 30 : 6;

			var area = map.lookAround(position.point, vision);
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
				// If we haven't selected the worker, move randomly toward the destination
				if(!isSelected)	target = movePosition(position.point, destination, area);
			
				// If we have selected the worker, or we tried to move and got nowhere
				// Generate a path toward the destination
				if(isSelected
				|| (target.x == position.point.x
				&& target.y == position.point.y)) {
					var path = generatePath(position.point, destination, area, isSelected);
					if(path == null) {
						trace(node.entity.name + " failed to reach the task target.");
						factory.dropTask(node.entity);
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
				node.entity.add(new StationaryMarker());
			}

			// The target position is safe, move there
			position.point = target;
		}
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

	
}


typedef PathNode = {
	var index:Int;
	var parent:Null<PathNode>;
};