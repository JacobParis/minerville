package systems;

//import openfl.display.DisplayObject;
//import openfl.display.DisplayObjectContainer;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.core.System;

import components.Health;
import components.TileImage;
import components.ai.Walking;
import components.markers.ClickedEh;
import components.tocks.BlockTock;

import services.EntityFactory;
import services.GameDataService;
import services.TileMapService;

import nodes.BlockNode;

/**
 *  This System operates on Block tiles
 *  
 *  When a tile is clicked it will start to mine it
 *  
 *  When a block is dead it will request ore and destroy the block
 */
class BlockSystem extends System {
	private var engine:Engine;
    private var nodes:NodeList<BlockNode>;
	private var data:GameDataService;

    public function new() {
        super();
		this.data = GameDataService.instance;
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		this.nodes = engine.getNodeList(BlockNode);
		
	}
	
	override public function update(time:Float):Void {
		for (node in this.nodes) {
			//var component:Component = node.component;
			if(node.entity.has(ClickedEh)) {
				node.entity.remove(ClickedEh);

				this.engine.getEntityByName("James")
				.add(new Walking(node.position.x, node.position.y, node.entity));		
				/*
				if(!node.entity.has(BlockTock)) {
					if(data.miners > 0) {
						data.useMiner();
						node.entity.add(new BlockTock( -1 ));
					}
					
				}*/
			}

			node.tile.tile.id = 2;
			
			if(node.health.value == 0) {
				data.requestOre();
				data.restoreMiner();
				TileMapService.instance.destroyBlock(node.entity);
			}
		}
	}
}