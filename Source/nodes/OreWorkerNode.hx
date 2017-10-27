package nodes;

import ash.core.Node;

import components.TilePosition;
import components.Worker;
import components.Items;

class OreWorkerNode extends Node<OreWorkerNode> {
    public var ore:Ore;
    public var position:TilePosition;
    public var worker:Worker;
	
}