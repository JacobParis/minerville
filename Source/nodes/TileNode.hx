package nodes;

import ash.core.Node;

import components.TilePosition;
import components.TileImage;

class TileNode extends Node<TileNode> {
    public var position:TilePosition;
    public var tile:TileImage;
}