package systems;

import ash.core.Engine;
import ash.core.System;

import components.Markers;

import services.UIService;

class EventSystem extends System {
	private var engine:Engine;
    public function new() {
        super();
    }
	
	// REMEMBER TO REGISTER THIS System
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;

	}
	
	override public function update(_):Void {
		var base = engine.getEntityByName("BASE");

		if(base == null) return;
		if(!base.has(ClickMarker)) return;

		base.remove(ClickMarker);

		UIService.instance.showNotifications();

		
	}
	
	/*
	public function tock(_):Void {
		// REMEMBER TO REGISTER THIS TICKER
		for (node in engine.getNodeList(EventNode)) {
			//var component:Component = node.component;
			
		}
	}
	*/
	
	/*
	private function updateNodes<TNode:Node<TNode>>(nodeClass:Class<TNode>) {
		for(node in engine.getNodeList(nodeClass)) {
		
		}
	}
	*/
}