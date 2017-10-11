package components;

import components.Task;

class TaskBid {
    public var task:Task;
    public var bid:Float;

    public function new(task:Task, bid:Float) {
        this.task = task;
        this.bid = bid;
    }

}