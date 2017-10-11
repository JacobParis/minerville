package nodes;

import ash.core.Node;

// import components
import components.Position;
import components.Task;
import components.Worker;

class TaskWorkerNode extends Node<TaskWorkerNode> {
    public var position:Position;
    public var worker:Worker;
    public var task:Task;
}