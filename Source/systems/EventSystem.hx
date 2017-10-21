package systems;

import haxe.ui.core.Screen;
import haxe.ui.components.Label;
import haxe.ui.components.Button;
import haxe.ui.containers.dialogs.DialogOptions;
import haxe.ui.macros.ComponentMacros;


import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.markers.ClickedEh;
import components.GameEvent;

import enums.EventTypes;

import nodes.EventNode;

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
		if(!base.has(ClickedEh)) return;

		base.remove(ClickedEh);

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