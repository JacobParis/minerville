package services;

import ash.core.Entity;

import components.Health;
import components.Position;
import components.Task;
import components.Worker;

import util.Point;
import util.Util;

import util.ds.Prioritizable;
import util.ds.ArrayedQueue;
import util.ds.Queue;
class TaskService {
    public static var instance(default, null):TaskService = new TaskService();
    public var queue:Queue<Task>;

    private function new() {
        this.queue = new ArrayedQueue();
    }
    
    public function initialize():TaskService {
        return this;
    }
	
    public function addTask(task:Task) {
        this.queue.enqueue(task);
    }
}



enum Skills {
    MINE;
    WALK;
    CARRY;
    ATTACK;
}