package nodes;

import ash.core.Node;

import components.Ore;
import components.TilePosition;
import components.TileImage;

class OreNode extends Node<OreNode> {
    public var position:TilePosition;
    public var ore:Ore;
    public var tile:TileImage;
}