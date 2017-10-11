package systems;

import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;

import components.ai.Mining;

import components.Task;
import components.TaskBid;

import nodes.AINode;
import nodes.BidNode;
import nodes.TaskWorkerNode;


import services.TaskService;

class TaskSystem extends System {
	private var engine:Engine;
	private var tasks:TaskService;
	private var nodes:NodeList<AINode>;

	private var currentTime:Float;
    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		this.nodes = engine.getNodeList(AINode);
		this.tasks = TaskService.instance;
	}
	
	override public function update(time:Float):Void {
		
		
		/* All active tasks will be in this queue until completed.
		When they are accepted by a worker, they are moved to the 
		bottom of the queue and are not removed. */
		currentTime += time;

		if(!tasks.queue.isEmpty()) {
			// Run through the list of tasks
			for(task in tasks.queue) {
				if(task.timePosted == 0) task.timePosted = currentTime;

				for (node in this.nodes) {
					trace("Available Node");
					// Remove workers that have tasks
					if(node.entity.has(Task)) continue;
					if(node.entity.has(Mining)) continue;
					
					if(node.entity.has(TaskBid)) {
						var bid:TaskBid = node.entity.get(TaskBid);
						if(bid.task == task) continue;
					}
					var suitability:Float;
					var threshold:Float;
					switch(task.action) {
						case MINE: threshold = node.worker.mineThreshold();
						case WALK: threshold = node.worker.carryThreshold();
						case CARRY: threshold = node.worker.carryThreshold();
						case ATTACK: threshold = node.worker.attackThreshold();
					}

					var base = (1.0 / task.difficulty) - threshold;
					suitability = base + (currentTime - task.timePosted) / 10000.0;

					trace(suitability, threshold);

					if(suitability > 0) {
						node.entity.add(new TaskBid(task, suitability));
					}
				}
			}
		}

		
	}
	
	
	public function tock(time:Float):Void {
		for (node in engine.getNodeList(BidNode)) {
			var task:Task = node.bid.task;
			var queue = TaskService.instance.queue;
			if(queue.contains(task)) {
				TaskService.instance.queue.remove(task);
				node.entity.add(task);
			}
			node.entity.remove(TaskBid);
		}
	}
	
}