package services;

import haxe.Json;
import openfl.Assets;

import util.Util;

class TechService {
    public static var instance(default, null):TechService = new TechService();
    private var carryTech:Array<TechDefinition>;
    private var mineTech:Array<TechDefinition>;
    private var buildTech:Array<TechDefinition>;

    private function new() {}
    
    public function initialize():TechService {
        var json = Json.parse(Assets.getText("assets/techtree.json"));
        this.carryTech = cast json.carry;
        this.mineTech = cast json.mine;
        this.buildTech = cast json.build;

        return this;
    }
	
    private function getTechFromName(name:String, category:Categories):Null<TechDefinition> {
        var array:Array<TechDefinition>;

        switch(category) {
            case CARRY: array = this.carryTech;
            case MINE: array = this.mineTech;
            case BUILD: array = this.buildTech;
        }

        for(tech in array) {
            if(tech.name == name) return tech;
        }

        return null;
    }

    public function isTechUnlocked(name:String, category:Categories):Bool {
        var tech = getTechFromName(name, category);
        //trace("Checking if " + name +  " is unlocked.");Main.log(tech);
        return tech.purchased;
    }

	public function update(time:Float):Void {
        
	}
}

enum Categories {
    CARRY;
    MINE;
    BUILD;
}
class TechDefinition {
    public var name:String;
    public var displayName:String;
    public var description:String;
    public var dependencies:Array<String>;

    public var purchased:Bool = false;
    public var visible:Bool;
}