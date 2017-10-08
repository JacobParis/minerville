package systems;

//import openfl.display.DisplayObject;
//import openfl.display.DisplayObjectContainer;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;

import components.Health;
import components.TileImage;

import components.markers.DeadEh;

import components.tocks.Tock;
import components.tocks.BlockTock;

import nodes.BlockTockNode;

import services.GameDataService;

import util.Util;

class TockSystem extends System {
    private var blockNodes:NodeList<BlockTockNode>;

    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.blockNodes = engine.getNodeList(BlockTockNode);
		
	}
	
	override public function update(time:Float):Void {
		//for (node in this.nodes) {
			//var component:Component = node.component;
			
		//}
	}

	public function tock(time:Float):Void {
		for (node in this.blockNodes) {
			var blockTock:BlockTock = cast node.tock;
			var health:Health = node.entity.get(Health);
			var tile:TileImage = node.entity.get(TileImage);
			health.value += blockTock.health;
			tile.tile.id = 3;
			if(health.value == 0) {
				node.entity.add(new DeadEh());
				node.entity.remove(BlockTock);
			}
		}

		/** Stat modification	 */
		var data = GameDataService.instance;
		if(data.ore > 0) {
			while(data.currentBake > data.bakeTime) {
				data.gold += data.bakeBatch + Util.rnd(0, 5);
				data.ore -= 1;
				data.currentBake -= data.bakeTime;
			}

			data.currentBake += data.bakeRate;
		}
	}
}