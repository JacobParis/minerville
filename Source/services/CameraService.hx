package services;

import openfl.display.DisplayObjectContainer;

import openfl.events.Event;
import openfl.events.MouseEvent;

import openfl.geom.Matrix;

import interfaces.InputListener;

import util.Util;

/**
 *  This Service controls panning and zooming and the inputs required
 *  to make either of those functions work
 */
class CameraService implements InputListener {
    public static var instance(default, null):CameraService = new CameraService();
   
    public var subscribedEvents:Array<String>;
    
    private var startX:Float = 0;
    private var startY:Float = 0;
    private var targetX:Float = 0;
    private var targetY:Float = 0;
    private var zoom:Float = 1;

    private var container:DisplayObjectContainer;
    
    private var isMouseDown = false;
    private var mouseX:Float;
    private var mouseY:Float;

    public var isScrolling = false;
    private function new() {
    }
    
    public function initialize(container:DisplayObjectContainer):CameraService {
        this.container = container;

        this.subscribedEvents = [
            MouseEvent.MOUSE_DOWN,
            MouseEvent.MOUSE_UP,
            MouseEvent.MOUSE_WHEEL
        ];

        return this;
    }

    public function onEvent(e:Event) {
        switch(e.type) {
            case MouseEvent.MOUSE_DOWN: mouseDown();
            case MouseEvent.MOUSE_UP: mouseUp();
            case MouseEvent.MOUSE_WHEEL: mouseWheel(cast e);
        }
    }

    private function mouseWheel(e:MouseEvent) {
        this.zoom = e.delta > 0 ? 1.1 : 0.91;
        zoomCamera();
    }

    public function mouseDown() {
        this.mouseX = this.container.stage.mouseX;
        this.mouseY = this.container.stage.mouseY;
        this.startX = -this.container.x;
        this.startY = -this.container.y;

        this.isMouseDown = true;
    }

    public function mouseUp() {
        if(this.isScrolling) {
            this.isScrolling = false;
        } else {
            var zoom = this.container.transform.matrix.a;

            // The position relative to the window. If the user clicks on the center of the 320px window, will return 160 
            var clickX = (this.container.stage.mouseX);
            var clickY = (this.container.stage.mouseY);

            var halfWidth:Float = this.container.stage.stageWidth / 2.0;
            var halfHeight:Float = this.container.stage.stageHeight / 2.0;

            var clickFromCenterX = clickX - halfWidth;
            var clickFromCenterY = clickY - halfHeight;
            //trace("Relative to Center of Window", clickFromCenterX, clickFromCenterY);

            var scaledClickX = clickFromCenterX / zoom;
            var scaledClickY = clickFromCenterY / zoom;
            //trace("Scaled Relative to Window", scaledClickX, scaledClickY);
            
            var translatedClickX = scaledClickX + halfWidth;
            var translatedClickY = scaledClickY + halfHeight;
            //trace("Translated back to normal", translatedClickX, translatedClickY);
            
            var originX = (this.container.x - halfWidth) / zoom + halfWidth;
            var originY = (this.container.y - halfHeight) / zoom + halfHeight;

            var x = translatedClickX - originX;
            var y = translatedClickY - originY;
            EntityFactory.instance.markEntityAtPosition(x, y, "click");
        }
        this.isMouseDown = false;
    }

    private function zoomCamera() {
        var halfWidth:Float = this.container.stage.stageWidth / 2.0;
        var halfHeight:Float = this.container.stage.stageHeight / 2.0;
        var zoom = this.zoom;
        
        var matrix:Matrix;
        matrix = this.container.transform.matrix;
        matrix.translate(-halfWidth, -halfHeight);
        matrix.scale(zoom, zoom);
        matrix.translate(halfWidth, halfHeight);
        this.container.transform.matrix = matrix;
    }

    public function update(time:Float):Void {
        if(isMouseDown) {
            if(!this.isScrolling) {
                if(Util.fdiff(this.mouseX, container.stage.mouseX) > 5
                || Util.fdiff(this.mouseY, container.stage.mouseY) > 5) {
                    this.isScrolling = true;
                }
            }

            this.targetX = this.startX + this.mouseX - container.stage.mouseX;
            this.targetY = this.startY + this.mouseY - container.stage.mouseY;
            this.container.x = (this.container.x - this.targetX) / 2.0;
            this.container.y = (this.container.y - this.targetY) / 2.0;
        }
        
        
    }
}