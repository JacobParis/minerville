package services;

import haxe.Json;
import openfl.Assets;

import util.Util;

class TechService {
    public static var instance(default, null):TechService = new TechService();
    private var tech:Array<TechDefinition>;
    
    private function new() {}
    
    public function initialize():TechService {
        var json = Json.parse(Assets.getText("assets/techtree.json"));
        this.tech = cast json.tech;
        return this;
    }
	
    private function getTechFromName(name:String):Null<TechDefinition> {
        var array:Array<TechDefinition>;

        for(tech in this.tech) {
            if(tech.name == name) return tech;
        }

        return null;
    }

    public function isTechUnlocked(name:String):Bool {
        var tech = getTechFromName(name);
        //trace("Checking if " + name +  " is unlocked.");Main.log(tech);
        return tech.purchased;
    }

    public function getTech():Array<TechDefinition> {
        return this.tech;
    }

    private function setTechToPurchased(tech:TechDefinition) {
        
    }

    public function purchaseTech(tech:TechDefinition) {
        var index = this.tech.indexOf(tech);
        if(index == -1) return;

        var data = GameDataService.instance;
        if(tech.price > data.gold) return;

        data.gold -= tech.price;
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

class TechDefinition {
    public var name:String;
    public var displayName:String;
    public var description:String;
    public var dependencies:Array<String>;
    public var price:Int;

    public var purchased:Bool = false;
    public var visible:Bool;
}