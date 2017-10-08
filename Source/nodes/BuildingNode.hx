package nodes;

import ash.core.Node;

import components.Building;
import components.Position;
import components.TileImage;

class BuildingNode extends Node<BuildingNode> {
    public var position:Position;
    public var building:Building;
    public var tile:TileImage;

}