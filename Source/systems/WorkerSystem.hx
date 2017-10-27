package systems;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.GameEvent;

import services.EntityFactory;
import services.NotificationService;

import enums.Types;

import nodes.WorkerNode;

class WorkerSystem extends System {
	private var engine:Engine;
    public function new() {
        super();
    }
	
	// REMEMBER TO REGISTER THIS System
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		
	}
	
	override public function update(_):Void {
		for (node in engine.getNodeList(WorkerNode)) {
			//var component:Component = node.component;
			
		}
	}
	
	
	public function tock(_):Void {
		// REMEMBER TO REGISTER THIS TICKER
		for (node in engine.getNodeList(DeadWorkerNode)) {
			//var component:Component = node.component;

			var event = new GameEvent(EventTypes.FATALITY, node.entity.name + " was killed by " + node.dead.cause);
			NotificationService.instance.addNotification(event);

			EntityFactory.instance.destroyEntity(node.entity);
		}
	}
	
	
	/*
	private function updateNodes<TNode:Node<TNode>>(nodeClass:Class<TNode>) {
		for(node in engine.getNodeList(nodeClass)) {
		
		}
	}
	*/
}