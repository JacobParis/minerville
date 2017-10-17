package nodes;

import ash.core.Node;

import components.Building;
import components.TilePosition;
import components.TileImage;

class BuildingNode extends Node<BuildingNode> {
    public var position:TilePosition;
    public var building:Building;
    public var tile:TileImage;

}