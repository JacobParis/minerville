package services;

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

import services.TaskService;

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

       

        Assets.loadBitmapData("assets/ui.png")
        .onComplete(function (bitmapData:BitmapData) {
            var tileset = new Tileset(bitmapData);

            GOLD = tileset.addRect(new Rectangle(0, 0, GameConfig.tileSize, GameConfig.tileSize));
            ORE = tileset.addRect(new Rectangle(0, GameConfig.tileSize, GameConfig.tileSize, GameConfig.tileSize));
            ORE_GLOW = tileset.addRect(new Rectangle(48, GameConfig.tileSize, GameConfig.tileSize, GameConfig.tileSize));
            PICKAXE = tileset.addRect(new Rectangle(0, GameConfig.tileSize * 2, GameConfig.tileSize, GameConfig.tileSize));
            PICKAXE_GLOW = tileset.addRect(new Rectangle(48, GameConfig.tileSize * 2, GameConfig.tileSize, GameConfig.tileSize));

            this.tilemap = new Tilemap(container.stage.stageWidth, 60, tileset);
            this.container.addChild(this.tilemap);

            this.goldTile = new Tile(GOLD, 0, 8);
            this.tilemap.addTile(goldTile);

            goldText = addTextField(60, 12, "0");

            this.oreTile = new Tile(ORE, 120, 8);
            this.tilemap.addTile(oreTile);

            oreText = addTextField(180, 12, "0");

            this.pickaxeTile = new Tile(PICKAXE, 240, 8);
            this.tilemap.addTile(pickaxeTile);

            pickaxeText = addTextField(300, 12, "0");

            this.container.addEventListener(MouseEvent.MOUSE_UP, function(m:MouseEvent) {
                if(this.curtain.visible) {
                    this.curtain.visible = false;
                }
                if(this.container.stage.mouseX > 120
                && this.container.stage.mouseX < 240) {
                    if(data.gold > 300) {
                        data.buyRefinery();
                    }
                }
                if(this.container.stage.mouseX > 240) {
                    Main.log(TaskService.instance.getAllTasks());
                }
            });

        });

        this.curtain = new Sprite();
        var background = new Sprite();
        background.graphics.beginFill(0x050915, 0.8);
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
        this.curtainText.text = "Welcome!";

        this.curtainText.setTextFormat(largeFormat);
        this.curtain.addChild(this.curtainText);

        this.curtainSubText = new TextField();
        this.curtainSubText.autoSize = TextFieldAutoSize.CENTER;
        this.curtainSubText.x = this.container.stage.stageWidth / 2 - this.curtainSubText.width / 2;
        this.curtainSubText.y = this.container.stage.stageHeight / 2 + 40;

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

	public function update(time:Float):Void {
        this.goldText.text = data.gold;
        this.oreText.text = data.ore;
        this.pickaxeText.text = data.miners;

        if(data.gold > 100) {
            this.pickaxeTile.id = PICKAXE_GLOW;
        } else {
            this.pickaxeTile.id = PICKAXE;
        }

        if(data.gold > 300) {
            this.oreTile.id = ORE_GLOW;
        } else {
            this.oreTile.id = ORE;
        }
	}
}