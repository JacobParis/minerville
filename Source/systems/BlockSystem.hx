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
import components.TileImage;
import components.ai.Walking;
import components.markers.ClickedEh;
import components.tocks.BlockTock;

import services.EntityFactory;
import services.GameDataService;
import services.TileMapService;

import nodes.BlockNode;
import nodes.OreNode;

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
		for (node in engine.getNodeList(BlockNode)) {
			if(node.entity.has(ClickedEh)) {
				node.entity.remove(ClickedEh);

				this.engine.getEntityByName("James")
				.add(new Walking(node.position.x, node.position.y, node.entity));		
			}

			node.tile.tile.id = 2;
			
			if(node.health.value == 0) {
				data.restoreMiner();
				TileMapService.instance.destroyBlock(node.entity);
			}
		}

		for (node in engine.getNodeList(OreNode)) {
			if(node.entity.has(ClickedEh)) {
				node.entity.remove(ClickedEh);
			
				this.engine.getEntityByName("James")
				.add(new Walking(node.position.x, node.position.y, node.entity));		
				
			}
		}
	}

}