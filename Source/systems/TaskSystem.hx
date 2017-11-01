package systems;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.Behaviours;
import components.Items;
import components.Markers;
import components.TilePosition;
import components.Task;
import components.TaskBid;
import components.Worker;

import enums.Types;

import nodes.WorkerNode;
import nodes.BidNode;

import services.TaskService;

import util.Util;
class TaskSystem extends System {
	private var engine:Engine;
	private var service:TaskService;
	private var nodes:NodeList<WorkerNode>;

	private var tasks:Array<Task>;

	private var currentTime:Float;
    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		this.nodes = engine.getNodeList(WorkerNode);
		this.service = TaskService.instance;
	}
	
	override public function update(time:Float):Void {
		currentTime += time;
	}
	
	
	public function tock(_):Void {
		if(!service.hasTasks()) return;
		var queue = service.getAllTasks();

		// Run through the list of tasks
		for(task in queue) {
			// Clean up bad tasks
			if(task.target == null || engine.getEntityByName(task.target.name) == null) {
				TaskService.instance.removeTask(task);
			}

			if(task.timePosted == 0) task.timePosted = currentTime;
			for (node in engine.getNodeList(WorkerNode)) {
				// Remove workers that have tasks
				if(node.entity.has(Task)) continue;
				if(node.entity.has(Mining)) continue;
				if(node.entity.has(Walking)) continue;
				if(node.entity.has(Marker)) continue;
			
				//trace("		has no task and is not mining");
				if(node.entity.has(TaskBid)) {
					var bid:TaskBid = node.entity.get(TaskBid);
					if(bid.task == task) continue;
					if(bid.task.priority >= task.priority) continue;
				}
				
				var suitability:Float;
				var threshold:Float;
				switch(task.action) {
					case MINE: threshold = node.worker.mineThreshold();
					case WALK: threshold = node.worker.carryThreshold();
					case CARRY: threshold = node.worker.carryThreshold();
					case ATTACK: threshold = node.worker.attackThreshold();
				}
				//trace(node.entity.name);
				// TODO handle carry limit here
				if(task.action == SkillTypes.CARRY) {
					if(node.entity.has(ToolMining) && task.target.has(ToolMining)) {
						if(node.entity.get(ToolMining).strength > task.target.get(ToolMining).strength)
							continue;
						}
				}

				var base = (1.0 / task.difficulty) - threshold;
				suitability = base + (currentTime - task.timePosted) / 10000.0;
				if(Util.chance(suitability) || task.priority > 1) { // Currently returning values around 0.9
					//trace("		and made a bid!");
					if(node.entity.has(TaskBid)) node.entity.remove(TaskBid);
					
					node.entity.add(new TaskBid(task, suitability));
				} else {
					//trace("		and chose not to make a bid.");
				}
			}

			// If there are no longer available workers, quit
			if(engine.getNodeList(BidNode).empty) return;

			var winningBid = 0.0;
			var winningEntity = null;

			for (node in engine.getNodeList(BidNode)) {
				// Remove workers that have tasks
				if(node.entity.has(Task)) continue;
				if(node.entity.has(Mining)) continue;
				if(node.entity.has(Walking)) continue;
				if(node.entity.has(Marker)) continue;

				if(task.target != node.bid.task.target) continue;
				if(task.action != node.bid.task.action) continue;

				if(node.bid.value > winningBid) {
					winningBid = node.bid.value;
					winningEntity = node.entity;
				}

				winningEntity.remove(TaskBid);
			}

			if(winningBid > 0) {
				var worker:Worker = winningEntity.get(Worker);
				var position:TilePosition = winningEntity.get(TilePosition);
				task.estimatedTime = worker.estimateTaskLength(task, position.point);
				winningEntity.add(task);
				TaskService.instance.removeTask(task);
			}
		}

		for (node in engine.getNodeList(BidNode)) {
			node.entity.remove(TaskBid);
		}
	}
	
}