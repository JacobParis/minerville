package systems;

import ash.core.Engine;
import ash.core.System;

import components.GameEvent;
import components.Items;
import components.TileImage;

import services.EntityFactory;
import services.TileMapService;
import services.NotificationService;

import enums.Types;

import nodes.WorkerNode;

/**
 *  This is the generic worker system that operates on the various
 *  permutations of worker components. As each node gets larger, it 
 *  should fork off into its own system
 */
class WorkerSystem extends System {
	private var engine:Engine;
    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		
	}
	
	public function tock(_):Void {
		/**
		 *  Remove dead workers and notify the player
		 */
		for (node in engine.getNodeList(DeadWorkerNode)) {
			var event = new GameEvent(EventTypes.FATALITY, node.entity.name + " was killed by " + node.dead.cause);
			NotificationService.instance.addNotification(event);

			EntityFactory.instance.destroyEntity(node.entity);
		}

		/**
		 *  Change the animation frame based on component sets
		 *  Might be replaced with an animation system eventually
		 */
		for (node in engine.getNodeList(WorkerNode)) {
			if(!node.entity.has(TileImage)) continue;

			var tileImage:TileImage = node.entity.get(TileImage);
			if(node.entity.has(Ore)) {
				tileImage.id = TileMapService.instance.enumMap.get(TileTypes.WORKER_ORE);
			} else {
				tileImage.id = TileMapService.instance.enumMap.get(TileTypes.WORKER);
			}
		}
	}
}