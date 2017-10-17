package nodes;

import ash.core.Node;

// import components
import components.TilePosition;
import components.Worker;

class AINode extends Node<AINode> {
    public var position:TilePosition;
    public var worker:Worker;
}