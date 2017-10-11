package nodes;

import ash.core.Node;

import components.ai.Mining;
import components.Position;
import components.Worker;

class MiningWorkerNode extends Node<MiningWorkerNode> {
    public var mining:Mining;
    public var position:Position;
    public var worker:Worker;
	
}