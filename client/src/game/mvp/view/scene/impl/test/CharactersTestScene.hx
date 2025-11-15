package game.mvp.view.scene.impl.test;

import h2d.Bitmap;
import game.mvp.view.scene.basic.BasicScene;

class CharactersTestScene extends BasicScene {
    private var bitmaps:Array<Bitmap> = [];

    public function new() {
        super();

        
    }

    public function start():Void {
        trace("CharactersTestScene started");
    }

    public function destroy():Void {
        trace("CharactersTestScene destroyed");
    }

    public function customUpdate(dt:Float, fps:Float):Void {
        trace("CharactersTestScene customUpdate");
    }
}