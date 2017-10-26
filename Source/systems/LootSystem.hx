package systems;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import services.EntityFactory;

import nodes.LootNode;
import nodes.ExpiryNode;

class LootSystem extends System {
	private var engine:Engine;
	private var factory:EntityFactory;

    public function new() {
        super();
    }
	
	// REMEMBER TO REGISTER THIS System
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		
	}
	
	override public function update(_):Void {
		for (node in engine.getNodeList(LootNode)) {
			//var component:Component = node.component;
			
		}
	}
	
	
	public function tock(_):Void {
		// REMEMBER TO REGISTER THIS TICKER
		for (node in engine.getNodeList(ExpiryNode)) {
			if(node.expiry.remaining <= 0) {
				EntityFactory.instance.destroyEntity(node.entity);
				continue;
			}

			node.expiry.remaining -= 1;
		}
	}
	
	
	/*
	private function updateNodes<TNode:Node<TNode>>(nodeClass:Class<TNode>) {
		for(node in engine.getNodeList(nodeClass)) {
		
		}
	}
	*/
}