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
import util.ds.ArrayedStack;
import util.ds.Queue;
import util.ds.Stack;

class TaskService {
    public static var instance(default, null):TaskService = new TaskService();
    public var queue:Queue<Task>;
    public var stack:Stack<Task>;
    private function new() {
        this.queue = new ArrayedQueue();
        this.stack = new ArrayedStack();
    }
    
    public function initialize():TaskService {
        return this;
    }
	
    public function addTask(task:Task, prioritize:Bool = false) {
        if(prioritize) {
            trace("Add priority task!");
            for(s in this.stack) {
                if(s.action == task.action
                && s.target == task.target)
                    this.stack.remove(s);
            }
            task.priority = 10;
            this.stack.push(task);
        } else {
            for(q in this.queue) {
                if(q.action == task.action
                && q.target == task.target)
                    return;
            }

            switch(task.action) {
                case MINE: task.priority = 1;
                case CARRY: task.priority = 2;
                case ATTACK: task.priority = 3;
                case WALK: task.priority = 0;
            }
            this.queue.enqueue(task);
        }
    }

    public function getTask():Null<Task> {
        if(this.stack.size > 0) {
            return this.stack.pop();
        }

        if(this.queue.size > 0) {
            return this.queue.dequeue();
        }

        return null;
    }

    public function removeTask(task:Task):Void {
        for(s in this.stack) {
            if(task.action == s.action
            && task.target == s.target) {
                this.stack.remove(s);
                return;
            }
        }
        
        for(q in this.queue) {
            if(q.action == task.action
            && q.target == task.target) {
                this.queue.remove(q);
                return;
            }
        }
    }


    public function getAllTasks():Array<Task> {
        var tasks = new Array<Task>();
        for(q in this.queue) {
            tasks.push(q);
        }
        
        for(s in this.stack) {
            tasks.push(s);
        }
        tasks.reverse();
        return tasks;
    }

    public function hasTasks():Bool {
        if(this.stack.size == 0 && this.queue.size == 0) {
            return false;
        }

        return true;
    }
}



enum Skills {
    MINE;
    WALK;
    CARRY;
    ATTACK;
}