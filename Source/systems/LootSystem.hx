package systems;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.Task;
import components.Properties;

import services.EntityFactory;
import services.TaskService;
import services.TechService;

import nodes.LootNode;
import nodes.ExpiryNode;

import util.Util;

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

		for (node in engine.getNodeList(LootNode)) {
			// Randomly ask to be collected
			if(TechService.instance.isTechUnlocked("search-ore")) {
				if(node.entity.has(Stimulus)) {
					TaskService.instance.addTask(new Task(CARRY, node.entity), node.entity.get(Stimulus).strength);
				} else if(Util.chance(0.8)) {
					TaskService.instance.addTask(new Task(CARRY, node.entity), 2);
				}
			}
		}
	}
	
	
	/*
	private function updateNodes<TNode:Node<TNode>>(nodeClass:Class<TNode>) {
		for(node in engine.getNodeList(nodeClass)) {
		
		}
	}
	*/
}