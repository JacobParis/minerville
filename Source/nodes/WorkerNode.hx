package nodes;

import ash.core.Node;

// import components
import components.TilePosition;
import components.Worker;

class WorkerNode extends Node<WorkerNode> {
    public var position:TilePosition;
    public var worker:Worker;
}