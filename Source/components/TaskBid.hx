package components;

import components.Task;

class TaskBid {
    public var task:Task;
    public var value:Float;

    public function new(task:Task, value:Float) {
        this.task = task;
        this.value = value;
    }

}