package nodes;

import ash.core.Node;

import components.Markers;
import components.TilePosition;
import components.TileImage;

class BuildingNode extends Node<BuildingNode> {
    public var position:TilePosition;
    public var building:BuildingMarker;
    public var tile:TileImage;

}