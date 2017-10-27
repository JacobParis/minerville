package nodes;

import ash.core.Node;

import components.Behaviours;
import components.TilePosition;
import components.Worker;

class MiningWorkerNode extends Node<MiningWorkerNode> {
    public var mining:Mining;
    public var position:TilePosition;
    public var worker:Worker;
	
}