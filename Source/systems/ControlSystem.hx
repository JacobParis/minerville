package systems;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.core.System;

import components.markers.ClickedEh;
import components.Marker;
import components.Stationary;
import components.Task;
import components.TileImage;
import components.TilePosition;
import components.Worker;

import components.ai.Mining;
import components.ai.Walking;

import nodes.WorkerNode;
import nodes.BlockNode;
import nodes.LootNode;

import services.EntityFactory;
import services.TaskService;
import services.TileMapService;


class ControlSystem extends System {
	private var engine:Engine;
	private var markedEntity:Entity;

    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		
	}
	
	override public function update(_):Void {
		for (node in engine.getNodeList(WorkerNode)) {
			// Handle click
			if(!node.entity.has(ClickedEh)) 
				continue;

			node.entity.remove(ClickedEh);

			if(this.markedEntity != null && this.markedEntity.has(Marker))
				this.markedEntity.remove(Marker);

			// Deselect if worker already selected
			if(node.entity == this.markedEntity) {
				this.markedEntity = null;
				continue;
			}

			node.entity.add(new Marker(node.entity.name));
			this.markedEntity = node.entity;

			// Remove any current tasks
			EntityFactory.instance.dropTask(this.markedEntity);

			if(!this.markedEntity.has(Stationary))
				this.markedEntity.add(new Stationary());
		}

		for (node in engine.getNodeList(BlockNode)) {
			// Handle click
			if(!node.entity.has(ClickedEh)) 
				continue;

			node.entity.remove(ClickedEh);
			trace("Clicked on block!");
			

			var task = new Task(Skills.MINE, node.entity);
			if(this.markedEntity == null) {
				// Send to Task Allocator
				TaskService.instance.addTask(task, 10);
			} else assignTask(this.markedEntity, task);


		}

		for (node in engine.getNodeList(LootNode)) {
			// Handle click
			if(!node.entity.has(ClickedEh)) 
				continue;

			node.entity.remove(ClickedEh);

			trace("Clicked on ore!");
			var task = new Task(Skills.CARRY, node.entity);
			if(this.markedEntity == null) {
				// Send to Task Allocator
				TaskService.instance.addTask(task, 10);
			} else assignTask(this.markedEntity, task);
		}
	}
	
	private function assignTask(entity:Entity, task:Task) {
		// Assign directly to worker
			if(entity.has(Task)) EntityFactory.instance.dropTask(entity);

			var position:TilePosition = entity.get(TilePosition);
			var worker:Worker = entity.get(Worker);
			task.estimatedTime = worker.estimateTaskLength(task, position.point);
			entity.add(task);
	}

	public function tock(_):Void {
		// REMEMBER TO REGISTER THIS TICKER

		if(this.markedEntity == null) return;
	}
	
	
	/*
	private function updateNodes<TNode:Node<TNode>>(nodeClass:Class<TNode>) {
		for(node in engine.getNodeList(nodeClass)) {
		
		}
	}
	*/
}