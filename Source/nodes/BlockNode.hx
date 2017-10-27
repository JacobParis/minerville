package nodes;

import ash.core.Node;

import components.Properties;
import components.TilePosition;
import components.TileImage;

class BlockNode extends Node<BlockNode> {
    public var position:TilePosition;
    public var health:Health;
    public var tile:TileImage;
}