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
	private var service:TaskService;
	private var nodes:NodeList<AINode>;

	private var tasks:Array<Task>;

	private var currentTime:Float;
    public function new() {
        super();
    }
	
	override public function addToEngine(engine:Engine):Void {
		this.engine = engine;
		this.nodes = engine.getNodeList(AINode);
		this.service = TaskService.instance;
	}
	
	override public function update(time:Float):Void {
		
		
		/* All active tasks will be in this queue until completed.
		When they are accepted by a worker, they are moved to the 
		bottom of the queue and are not removed. */
		currentTime += time;

		

		
	}
	
	
	public function tock(time:Float):Void {
		if(service.hasTasks()) {
			// Run through the list of tasks
			for(task in service.getAllTasks()) {
				if(task.timePosted == 0) task.timePosted = currentTime;
				for (node in this.nodes) {
					
					
					// Remove workers that have tasks
					if(node.entity.has(Task)) {
						//trace("		has a task");
						continue;
					}

					if(node.entity.has(Mining)) {
						//trace("		is busy mining");
						continue;
					}
					
					//trace("		has no task and is not mining");
					if(node.entity.has(TaskBid)) {
						var bid:TaskBid = node.entity.get(TaskBid);
						if(bid.task == task) continue;
						if(bid.task.priority >= task.priority) {
							//trace("		has a higher priority bid.");
							continue;
						}
					}

					var suitability:Float;
					var threshold:Float;
					switch(task.action) {
						case MINE: threshold = node.worker.mineThreshold();
						case WALK: threshold = node.worker.carryThreshold();
						case CARRY: threshold = node.worker.carryThreshold();
						case ATTACK: threshold = node.worker.attackThreshold();
					}
					trace(node.entity.name);
					
					var base = (1.0 / task.difficulty) - threshold;
					suitability = base + (currentTime - task.timePosted) / 10000.0;
					if(Util.chance(suitability) || task.priority > 1) { // Currently returning values around 0.9
						trace("		and made a bid!");
							node.entity.remove(TaskBid);
						
						node.entity.add(new TaskBid(task, suitability));
					} else {
						trace("		and chose not to make a bid.");
					}
				}
			}
		}
		/**
			 * The bid system chooses the best worker for the job out of
			 *  all the workers that have applied for it. 
			 */

		
		var queue = service.getAllTasks();
		for(task in queue) {
			// If there are no longer available workers, quit
			if(engine.getNodeList(BidNode).empty) {
				//trace("There are no available workers.");
				return;
			}

			if(task.target == null) {
				trace("Task target is null");
				TaskService.instance.removeTask(task);
			}

			var bestBid = {
				value: 0.0,
				entity: new Entity()
			};

			for (node in engine.getNodeList(BidNode)) {
				if(task.target == node.bid.task.target
				&& task.action == node.bid.task.action) {
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
				TaskService.instance.removeTask(task);
			}
		}

		for (node in engine.getNodeList(BidNode)) {
			node.entity.remove(TaskBid);
		}
	}
	
}