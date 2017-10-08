package graphics;

import openfl.display.Shape;

class AsciiView extends Shape
{
    public function new()
    {
        super();

        graphics.beginFill(0x00ccee);
        graphics.drawRect(0,0,32,32);
        graphics.endFill();

    }
}