package game.mvp.view.entities.collider;

import h2d.Bitmap;
import h2d.Tile;
import game.mvp.presenter.GamePresenter;
import game.mvp.model.entities.BaseEntityModel;
import game.mvp.model.entities.ColliderModel;

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
        final width = Math.floor(model.colliderWidth * GamePresenter.Config.engineConfig.unitPixels);
        final height = Math.floor(model.colliderHeight * GamePresenter.Config.engineConfig.unitPixels);
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
