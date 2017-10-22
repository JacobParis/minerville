package services;

import haxe.Json;
import openfl.Assets;

import util.Util;

class TechService {
    public static var instance(default, null):TechService = new TechService();
    private var carryTech:Array<TechDefinition>;
    private var mineTech:Array<TechDefinition>;
    private var buildTech:Array<TechDefinition>;
    private var tech:Array<TechDefinition>;
    
    private function new() {}
    
    public function initialize():TechService {
        var json = Json.parse(Assets.getText("assets/techtree.json"));
        this.carryTech = cast json.carry;
        this.mineTech = cast json.mine;
        this.buildTech = cast json.build;
        this.tech = cast json.tech;
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

    public function getTech():Array<TechDefinition> {
        return this.tech;
    }

    public function setTechToPurchased(tech:TechDefinition) {
        var index = this.tech.indexOf(tech);
        if(index == -1) return;

        tech.purchased = true;
        this.tech[index] = tech;
    }
    
    public function getPurchasedTech():Array<TechDefinition> {
        var array:Array<TechDefinition> = new Array<TechDefinition>();
        for(tech in this.tech) {
            if(tech.purchased) array.push(tech);
        }

        return array;
    }

    public function getAvailableTech():Array<TechDefinition> {
        var purchased = getPurchasedTech();

        var array:Array<TechDefinition> = new Array<TechDefinition>();
        for(tech in this.tech) {
            if(tech.purchased) continue;
            if(tech.dependencies == null) {
                array.push(tech);
                continue;
            }
            if(tech.dependencies.length == 0) {
                array.push(tech);
                continue;
            }
            (function ():Bool {
                for(dependency in tech.dependencies) {
                    var owned = false;
                    for(p in purchased) {
                        if(dependency == p.name) {
                            owned = true;
                            break;
                        }
                    }

                    if(owned == false) return false;
                }
                return true;
            })() ? array.push(tech) : continue;
        }

        return array;
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