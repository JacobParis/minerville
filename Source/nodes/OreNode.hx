package nodes;

import ash.core.Node;

import components.Ore;
import components.Position;
import components.TileImage;

class OreNode extends Node<OreNode> {
    public var position:Position;
    public var ore:Ore;
    public var tile:TileImage;
}