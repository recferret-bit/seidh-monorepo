package game.mvp.view.entities.terrain;

import h2d.Bitmap;

class TerrainEntity extends BaseGameEntityView {

    public function new(tile:h2d.Tile) {
        super();

        bitmap = new Bitmap(tile, this);
    }

}