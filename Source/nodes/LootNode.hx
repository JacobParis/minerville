package nodes;

import ash.core.Node;

import components.Markers;
import components.TilePosition;
import components.TileImage;

class LootNode extends Node<LootNode> {
    public var position:TilePosition;
    public var tile:TileImage;
    public var loot:LootMarker;
}