package systems;

import ash.core.Engine;
import ash.core.System;

import components.Properties;
import components.Items;
import components.TileImage;

import enums.Types;

import nodes.MiningWorkerNode;

import services.EntityFactory;
import services.TileMapService;

import util.Util;

class WorkerMiningSystem extends System {
	private var engine:Engine;
	private var factory:EntityFactory;
	private var map:TileMapService;

    public function new() {
        super();
    }
	
	// REMEMBER TO REGISTER THIS System
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		this.factory = EntityFactory.instance;
		this.map = TileMapService.instance;
	}
	
	public function tock(_):Void {
		/**
		 *  Deal damage to the block being mined
		 */
		for (node in engine.getNodeList(MiningWorkerNode)) {
			var blockHealth:Health = node.mining.block.get(Health);
			
			var strength = 1;			
			if(node.entity.has(ToolMining)) {
				var toolMining:ToolMining = node.entity.get(ToolMining);
				strength = toolMining.strength;
			}

			var hardness = 1;
			if(node.mining.block.has(Hardness)) {
				var hardnessComponent = node.mining.block.get(Hardness);
				hardness = hardnessComponent.value;
			}

			strength = Util.max(1, strength - hardness);
			blockHealth.value -= strength;

			// TODO delegate to animation system
			var blockTile:TileImage = node.mining.block.get(TileImage);
			blockTile.id = map.enumMap.get(TileTypes.WALL_DAMAGED);

			
			// Stop beating a dead quartz
			if(blockHealth.value <= 0) factory.dropTask(node.entity);
		}
	}
	
}