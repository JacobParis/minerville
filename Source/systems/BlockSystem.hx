package systems;

//import openfl.display.DisplayObject;
//import openfl.display.DisplayObjectContainer;
import haxe.Timer;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;


import components.Items;
import components.Markers;
import components.Properties;
import components.Task;
import components.TilePosition;
import components.Worker;
import components.GameEvent;

import enums.Types;

import services.CameraService;
import services.EntityFactory;
import services.GameDataService;
import services.NotificationService;
import services.TaskService;
import services.TechService;
import services.TileMapService;

import nodes.BlockNode;
import nodes.MarkerNode;
import nodes.LootNode;
import nodes.WorkerNode;

import util.Util;
import util.Point;


/**
 *  This System operates on Block tiles
 *  
 *  When a tile is clicked it will start to mine it
 *  
 *  When a block is dead it will request ore and destroy the block
 */
class BlockSystem extends System {
	private var engine:Engine;
	private var data:GameDataService;

    public function new() {
        super();
		this.data = GameDataService.instance;
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		
	}
	
	override public function update(_):Void {
		for ( node in engine.getNodeList(BlockNode)) {
			// TODO delegate to animation system
			if(node.tile.id == TileMapService.instance.enumMap.get(TileTypes.WALL_DAMAGED)) {
				if(node.entity.has(Hardness)) {
					var hardness = node.entity.get(Hardness).value - 1;
					node.tile.id = TileMapService.instance.enumMap.get(TileTypes.WALL) + hardness;
				}
			}
		}
	}

	public function tock(_) {
		for (node in engine.getNodeList(BlockNode)) {
			// Randomly ask to be mined
			if(TechService.instance.isTechUnlocked("search-dirt")) {
				if(node.entity.has(Hardness)) {
					// Harder rocks are exponentially less likely to be selected
					var chance = 0.5 / node.entity.get(Hardness).value / node.entity.get(Hardness).value;

					if(node.entity.has(Stimulus)) {
						TaskService.instance.addTask(new Task(SkillTypes.MINE, node.entity), node.entity.get(Stimulus).strength);
					} else if(Util.chance(chance)) {
						TaskService.instance.addTask(new Task(SkillTypes.MINE, node.entity));
					}

				}
			}

			// Kill if dead
			if(node.health.value <= 0) {
				TileMapService.instance.destroyBlock(node.entity);
				continue;
			}

			// TODO delegate to animation system
			if(node.tile.id == TileMapService.instance.enumMap.get(TileTypes.WALL_DAMAGED)) {
				if(node.entity.has(Hardness)) {
					var hardness = node.entity.get(Hardness).value - 1;
					node.tile.id = TileMapService.instance.enumMap.get(TileTypes.WALL) + hardness;
				}
			}
		}

		for (node in engine.getNodeList(LootNode)) {
			// Randomly ask to be collected
			if(TechService.instance.isTechUnlocked("search-ore")) {
				if(node.entity.has(Stimulus)) {
					TaskService.instance.addTask(new Task(SkillTypes.CARRY, node.entity), node.entity.get(Stimulus).strength);
				} else if(Util.chance(0.8)) {
					TaskService.instance.addTask(new Task(SkillTypes.CARRY, node.entity), 2);
				}
			}
		}

		// Cave-in
		if(Util.chance(0.01) && Util.chance(0.1)) {
			CameraService.instance.triggerShake();

			var block = EntityFactory.instance.findBlock();
			var cavein = "
			-X-
			XXX
			-X-";

			var position:TilePosition = block.get(TilePosition);

			var event = new GameEvent(EventTypes.DISASTER, "Cave-In at " + position.point);
			NotificationService.instance.addNotification(event);

			Timer.delay(function () {
				 var newPoints = TileMapService.instance.loadTilePattern(cavein, position.point.clone().add(-1,-1), true);


				for(cell in newPoints) {
					var crushedWorker = EntityFactory.instance.workerAt(cell.x, cell.y);
					if(crushedWorker == null) continue;

					trace("Crushed Worker");
					crushedWorker.add(new DeadMarker("cave-in"));


		
				}
			}, 400);

		}
	}

}