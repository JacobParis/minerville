package nodes;

import ash.core.Node;

import components.Position;
import components.TileImage;

class TileNode extends Node<TileNode> {
    public var position:Position;
    public var tile:TileImage;
}