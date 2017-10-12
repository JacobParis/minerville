package nodes;

import ash.core.Node;

import components.Position;
import components.Worker;
import components.Ore;

class OreWorkerNode extends Node<OreWorkerNode> {
    public var ore:Ore;
    public var position:Position;
    public var worker:Worker;
	
}