package systems;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.core.System;

import components.ai.Mining;

import components.Position;
import components.Task;
import components.TaskBid;
import components.Worker;

import nodes.AINode;
import nodes.BidNode;
import nodes.TaskWorkerNode;


import services.TaskService;

import util.Util;
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

					if(suitability > 0) { // Currently returning values around 0.9
						node.entity.add(new TaskBid(task, suitability));
					}
				}
			}
		}

		
	}
	
	
	public function tock(time:Float):Void {
		/**
			 * The bid system chooses the best worker for the job out of
			 *  all the workers that have applied for it. 
			 */

		var queue = TaskService.instance.queue;
		for(task in queue) {
			// If there are no longer available workers, quit
			if(engine.getNodeList(BidNode).empty) return;
			
			var bestBid = {
				value: 0.0,
				entity: new Entity()
			};

			for (node in engine.getNodeList(BidNode)) {
				if(task == node.bid.task) {
					if(node.bid.value > bestBid.value) {
						bestBid.value = node.bid.value;
						bestBid.entity = node.entity;
					}

					bestBid.entity.remove(TaskBid);
				}
			}

			if(bestBid.value > 0) {
				var worker:Worker = bestBid.entity.get(Worker);
				var position:Position = bestBid.entity.get(Position);
				task.estimatedTime = worker.estimateTaskLength(task, position.point);
				bestBid.entity.add(task);
				TaskService.instance.queue.remove(task);
			}
		}
	}
	
}