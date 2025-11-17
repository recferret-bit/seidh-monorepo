package game.mvp.view.entities.collider;

import engine.SeidhEngine;
import game.mvp.model.entities.BaseEntityModel;
import game.mvp.model.entities.ColliderModel;
import game.mvp.presenter.GamePresenter;
import h2d.Bitmap;
import h2d.Tile;

/**
 * Collider entity view extending BaseGameEntityView
 * Simple red rectangle visualization for colliders
 */
class ColliderEntityView extends BaseGameEntityView {
    
    public function new() {
        super();
    }
    
    /**
     * Initialize collider view
     */
    override public function initialize(model: BaseEntityModel): Void {
        super.initialize(model);

        // Calculate size based on model collider dimensions
        final width = Math.floor(model.colliderWidth * SeidhEngine.Config.unitPixels);
        final height = Math.floor(model.colliderHeight * SeidhEngine.Config.unitPixels);
        final tile = Tile.fromColor(0xFF0000, width, height).center();
        bitmap = new Bitmap(tile, this);
        bitmap.alpha = 0.9;
    }

    /**
     * Get collider model
     */
    public function getColliderModel(): ColliderModel {
        return cast(model, ColliderModel);
    }

}
