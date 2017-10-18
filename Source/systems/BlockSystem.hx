package systems;

//import openfl.display.DisplayObject;
//import openfl.display.DisplayObjectContainer;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;

import components.Health;
import components.Ore;
import components.Task;

import components.Worker;
import components.Stimulus;
import components.Marker;
import components.markers.ClickedEh;

import services.EntityFactory;
import services.GameDataService;
import services.TaskService;
import services.TechService;
import services.TileMapService;

import nodes.BlockNode;
import nodes.MarkerNode;
import nodes.OreNode;
import nodes.WorkerNode;

import util.Util;

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

	}

	public function tock(_) {
		for (node in engine.getNodeList(BlockNode)) {
			// Randomly ask to be mined
			if(TechService.instance.isTechUnlocked("search-dirt", Categories.MINE)) {
				if(node.entity.has(Stimulus)) {
					TaskService.instance.addTask(new Task(Skills.MINE, node.entity), node.entity.get(Stimulus).strength);
				} else if(Util.chance(0.5)) {
					TaskService.instance.addTask(new Task(Skills.MINE, node.entity));
				}
			}

			// Kill if dead
			if(node.health.value <= 0) {
				TileMapService.instance.destroyBlock(node.entity);
				continue;
			}

			// TODO delegate to animation system
			node.tile.tile.id = 2;
		}

		for (node in engine.getNodeList(OreNode)) {
			if(node.entity.has(Worker)) {
				engine.getNodeList(OreNode).remove(node);
				continue;
			}
			// Randomly ask to be collected
			if(TechService.instance.isTechUnlocked("search-ore", Categories.CARRY)) {
				if(node.entity.has(Stimulus)) {
					TaskService.instance.addTask(new Task(Skills.CARRY, node.entity), node.entity.get(Stimulus).strength);
				} else if(Util.chance(0.8)) {
					TaskService.instance.addTask(new Task(Skills.CARRY, node.entity), 2);
				}
			}
		}
	}

}