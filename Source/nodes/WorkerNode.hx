package nodes;

import ash.core.Node;

// import components
import components.Dead;
import components.TilePosition;
import components.Worker;

class WorkerNode extends Node<WorkerNode> {
    public var position:TilePosition;
    public var worker:Worker;
}

class DeadWorkerNode extends Node<DeadWorkerNode> {
    public var position:TilePosition;
    public var worker:Worker;
    public var dead:Dead;
}