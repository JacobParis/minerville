package services;

import components.Task;

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
	
    public function addTask(task:Task, priority:Float = 1) {
        for(q in this.queue) {
            if(q.action == task.action
            && q.target == task.target) {
                q.priority = priority;
                return;

            }
        }

        task.priority = priority;
        this.queue.enqueue(task);
    }

    public function getTask():Null<Task> {
        if(this.queue.size > 0) {
            return this.queue.dequeue();
        }

        return null;
    }

    public function removeTask(task:Task):Void {
        for(q in this.queue) {
            if(q.action == task.action
            && q.target == task.target) {
                this.queue.remove(q);
                return;
            }
        }
    }


    public function getAllTasks():Array<Task> {        
        var tasks = queue.toArray();
        tasks.sort(function (a:Task, b:Task) {
            if (a.priority < b.priority) return 1;
            else if (a.priority > b.priority) return -1;
            return 0;
        });

        return tasks;
    }

    public function hasTasks():Bool {
        return this.queue.size != 0;
    }
}



