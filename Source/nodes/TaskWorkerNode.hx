package nodes;

import ash.core.Node;

// import components
import components.TilePosition;
import components.Task;
import components.Worker;

class TaskWorkerNode extends Node<TaskWorkerNode> {
    public var position:TilePosition;
    public var worker:Worker;
    public var task:Task;
}