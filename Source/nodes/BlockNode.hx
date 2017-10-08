package nodes;

import ash.core.Node;

import components.Health;
import components.Position;
import components.TileImage;

class BlockNode extends Node<BlockNode> {
    public var position:Position;
    public var health:Health;
    public var tile:TileImage;
}