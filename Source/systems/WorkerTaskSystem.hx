package systems;

import haxe.ds.IntMap;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.core.System;

import components.Behaviours;
import components.Items;
import components.Properties;
import components.TilePosition;
import components.Markers;
import components.Path;
import components.Task;
import components.TileImage;
import components.Worker;

import enums.Types;

import nodes.WorkerNode;
import nodes.MiningWorkerNode;
import nodes.TaskWorkerNode;

import services.EntityFactory;
import services.GameDataService;
import services.TileMapService;

import util.RelativeArray2D;
import util.Point;
import util.Util;

class WorkerTaskSystem extends System {
	private var engine:Engine;
	private var map:TileMapService;
	private var factory:EntityFactory;

    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		this.map = TileMapService.instance;
		this.factory = EntityFactory.instance;

	}

	public function tock(time:Float):Void {
		for (node in engine.getNodeList(TaskWorkerNode)) {
			var isSelected = node.entity.has(Marker);
			
			// Drop task if it takes longer than expected
			node.task.timeTaken += 1;

			if(!isSelected && node.task.timeTaken > node.task.estimatedTime + 20) {
				factory.dropTask(node.entity);
				continue;
			}

			if(node.entity.has(Walking)) continue;

			// Travel to task
			if(Point.distance(node.position.point, node.task.location()) > 1) {
				node.entity.add(new Walking(node.task.location().x, node.task.location().y));
				continue;
			} 

			// We have arrived at our destination
			if(isSelected) trace(node.entity.name + " has reached their destination.");
			node.entity.add(new StationaryMarker());
			switch(node.task.action) {
				case MINE: mineBlock(node.entity, node.task);
				case CARRY: {
					if(node.task.target.has(LootMarker)) collectLoot(node.entity, node.task);
				}
				case ATTACK: 1;
				case WALK: completeWalk(node.entity, node.task);
			}
			
		}

		

		// TODO move to different system
		
	}

	
	private function mineBlock(entity:Entity,task:Task) {
		if(entity.has(Task)) entity.remove(Task);

		// TODO remove these -- good code should make them unnecessary
		if(entity.has(Mining)) entity.remove(Mining);
        if(entity.has(Path)) entity.remove(Path);

		var worker:Worker = entity.get(Worker);
		worker.train(MINE, entity.name);

		entity.add(new Mining(task.target));
		entity.add(new StationaryMarker());
	}

	private function collectLoot(entity:Entity, task:Task) {
		if(entity.has(Task)) entity.remove(Task);
		if(entity.has(Marker)) trace(entity.name + " is picking up....");

		if(task.target.has(ToolMining)) {
			if(entity.has(ToolMining)) {
				var target = task.target.get(ToolMining);
				var current = entity.get(ToolMining);
				if(target.strength > current.strength) {
					this.factory.dropLoot(entity.get(TilePosition).point, entity.remove(ToolMining));
				} else return;
			}

			entity.add(task.target.remove(ToolMining));
			factory.destroyEntity(task.target);
		}

		if(task.target.has(Ore)) {
			if(entity.has(Marker)) trace("... some ore!");
			entity.add(task.target.remove(Ore));
			factory.destroyEntity(task.target);

			var returnTask:Task = factory.getWalkingToBase();
			returnTask.estimatedTime = entity.get(Worker).estimateTaskLength(returnTask, entity.get(TilePosition).point);
			entity.add(returnTask);
			
		}
	}

	private function completeWalk(entity:Entity, task:Task) {
		//trace("completeWalk");
		if(entity.has(Marker)) trace(entity.name + " has arrived at the Base");
		if(task.target.name == BuildingTypes.BASE.getName()) {
			if(entity.has(Ore)) {
				if(entity.has(Marker)) trace(entity.name + " has dropped off Ore");
				entity.remove(Ore);
				var worker:Worker = entity.get(Worker);
				worker.train(SkillTypes.CARRY, entity.name);

				GameDataService.instance.requestOre();
			} else {
				trace("Worker did not have Ore");
			}
		}
		entity.remove(Task);
	}
}
