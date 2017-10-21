package services;

import haxe.ui.core.Screen;
import haxe.ui.components.Label;
import haxe.ui.components.Button;
import haxe.ui.containers.dialogs.DialogOptions;
import haxe.ui.macros.ComponentMacros;

import openfl.Assets;

import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.display.Tile;
import openfl.display.Graphics;
import openfl.display.Sprite;

import openfl.events.MouseEvent;

import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.geom.Rectangle;

import ash.core.Engine;

import nodes.EventNode;

import components.GameEvent;

import services.TaskService;
import services.NotificationService;

import util.Util;

/**
 *  This Service displays the UI on a layer above the main game 
 *  and contains event listeners to detect when UI buttons are clicked
 */
class UIService {
    public static var instance(default, null):UIService = new UIService();

    private var container:DisplayObjectContainer;
    private var tilemap:Tilemap;
    private var data:GameDataService;
    
    private var GOLD:Int = 0;
    private var ORE:Int = 1;
    private var ORE_GLOW:Int = 2;
    private var PICKAXE:Int = 3;
    private var PICKAXE_GLOW:Int = 4;

    private var goldTile:Tile;
    private var goldText:TextField;
    private var oreTile:Tile;
    private var oreText:TextField;
    private var pickaxeTile:Tile;
    private var pickaxeText:TextField;

    private var curtain:Sprite;
    private var curtainText:TextField;
    private var curtainSubText:TextField;

    private function new() {
        this.data = GameDataService.instance;
    }
    
    public function initialize(container:DisplayObjectContainer):UIService {
        this.container = container;

        this.container.addEventListener(MouseEvent.MOUSE_UP, function(m:MouseEvent) {      
            if(this.curtain.visible) {
                this.curtain.visible = false;
            }
        });

        this.curtain = new Sprite();
        var background = new Sprite();
        background.graphics.beginFill(0x1a237e, 1);
        background.graphics.drawRect(0,0,this.container.stage.stageWidth, this.container.stage.stageHeight);
        this.curtain.addChild(background);

        var largeFormat = new TextFormat(null, 40, 0xFFFFFF);
        largeFormat.align = TextFormatAlign.CENTER;

        var smallFormat = new TextFormat(null, 20, 0xCCCCCC);
        smallFormat.align = TextFormatAlign.CENTER;

        this.curtainText = new TextField();
        this.curtainText.autoSize = TextFieldAutoSize.CENTER;
        this.curtainText.x = this.container.stage.stageWidth / 2 - this.curtainText.width / 2;
        this.curtainText.y = this.container.stage.stageHeight / 2;
        this.curtainText.text = "Minerville";

        this.curtainText.setTextFormat(largeFormat);
        this.curtain.addChild(this.curtainText);

        this.curtainSubText = new TextField();
        this.curtainSubText.autoSize = TextFieldAutoSize.CENTER;
        this.curtainSubText.x = this.container.stage.stageWidth / 2 - this.curtainSubText.width / 2;
        this.curtainSubText.y = this.container.stage.stageHeight / 2 + 40;
        this.curtainSubText.text = "Dawn of the First Day";

        this.curtainSubText.setTextFormat(smallFormat);
        this.curtain.addChild(this.curtainSubText);

        this.container.addChild(this.curtain);
        
        return this;
    }
	
    public function showCurtain(?text:String, ?subText:String) {
        this.curtain.visible = true;

        if(text != null) {
            this.curtainText.text = text;
        }

        if(subText != null) {
            this.curtainSubText.text = subText;
        }
    }

    public function addTextField(x:Float, y:Float, ?defaultText:String):TextField {
        var textField = new TextField();
        textField.x = x;
        textField.y = y;
        textField.setTextFormat(new TextFormat(null, 30, 0xFFFFFF));

        if(defaultText != null) textField.text = defaultText;
        
        this.container.addChild(textField);

        return textField;
    }

    public function showNotifications() {
        var options = new DialogOptions();
		options.title = "Notifications";

		var dialog = ComponentMacros.buildComponent("assets/ui/events.xml");
		
		dialog.height = 400;

        var notifications = NotificationService.instance.getNotifications();
		for(note in notifications) {
			var button = new Button();
			button.text = note.type.getName() + ": " + note.value;
			button.styleNames = "notification";
			button.height = 40;
			dialog.addComponent(button);
		}

		Screen.instance.showDialog(dialog, options);
    }
	public function update(time:Float):Void {
       
	}
}