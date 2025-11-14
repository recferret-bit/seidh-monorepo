package game.mvp.view.scene.impl.test;

import h2d.Bitmap;
import game.resource.tilemap.ObjectsTilemapManager;
import game.mvp.view.scene.basic.BasicScene;

class ObjectsTilemapTestScene extends BasicScene {
    private var bitmaps:Array<Bitmap> = [];

    public function new() {
        super();

        ObjectsTilemapManager.instance.init();

        var yOffset:Float = 50;
        var xStart:Float = 50;
        var spacingBetweenTiles:Float = 10; // Gap between tiles

        // Consumables row
        var consumables:Array<TileType> = [
            TileType.POTION_RED,
            TileType.POTION_GREEN,
            TileType.POTION_BLUE,
            TileType.POTION_YELLOW,
            TileType.COIN,
            TileType.SALMON,
            TileType.SWORD
        ];
        var maxHeight = createBitmapsForCategory(consumables, xStart, yOffset, spacingBetweenTiles);
        yOffset += maxHeight + spacingBetweenTiles;

        // Runes row
        var runes:Array<TileType> = [
            TileType.RUNE_TYPE_ANY_LVL_1,
            TileType.RUNE_TYPE_1_LVL_2,
            TileType.RUNE_TYPE_1_LVL_3,
            TileType.RUNE_TYPE_2_LVL_2,
            TileType.RUNE_TYPE_2_LVL_3,
            TileType.RUNE_TYPE_3_LVL_2,
            TileType.RUNE_TYPE_3_LVL_3,
            TileType.RUNE_TYPE_4_LVL_2,
            TileType.RUNE_TYPE_4_LVL_3,
            TileType.RUNE_TYPE_5_LVL_2,
            TileType.RUNE_TYPE_5_LVL_3,
            TileType.RUNE_TYPE_6_LVL_2,
            TileType.RUNE_TYPE_6_LVL_3
        ];
        maxHeight = createBitmapsForCategory(runes, xStart, yOffset, spacingBetweenTiles);
        yOffset += maxHeight + spacingBetweenTiles;

        // Scrolls row
        var scrolls:Array<TileType> = [
            TileType.SCROLL_TYPE_ANY_LVL_1,
            TileType.SCROLL_TYPE_1_LVL_2,
            TileType.SCROLL_TYPE_1_LVL_3,
            TileType.SCROLL_TYPE_2_LVL_2,
            TileType.SCROLL_TYPE_2_LVL_3,
            TileType.SCROLL_TYPE_3_LVL_2,
            TileType.SCROLL_TYPE_3_LVL_3
        ];
        maxHeight = createBitmapsForCategory(scrolls, xStart, yOffset, spacingBetweenTiles);
        yOffset += maxHeight + spacingBetweenTiles;

        // Artifacts row
        var artifacts:Array<TileType> = [
            TileType.ARTIFACT_1
        ];
        maxHeight = createBitmapsForCategory(artifacts, xStart, yOffset, spacingBetweenTiles);
        yOffset += maxHeight + spacingBetweenTiles;

        // Icons row
        var icons:Array<TileType> = [
            TileType.ICON_BOOST_BLACK,
            TileType.ICON_SKILL_BACKGROUND,
            TileType.ICON_CLOSE,
            TileType.ICON_SCROLL,
            TileType.ICON_BOOST_BROWN,
            TileType.ICON_RUNE_BIG,
            TileType.ICON_RUNE_SMALL
        ];
        maxHeight = createBitmapsForCategory(icons, xStart, yOffset, spacingBetweenTiles);
        yOffset += maxHeight + spacingBetweenTiles;

        // Skills row
        var skills:Array<TileType> = [
            TileType.SKILL_ACTION_MAIN
        ];
        maxHeight = createBitmapsForCategory(skills, xStart, yOffset, spacingBetweenTiles);
        yOffset += maxHeight + spacingBetweenTiles;

        // Wealth row
        var wealth:Array<TileType> = [
            TileType.WEALTH_COINS,
            TileType.WEALTH_TEETH,
            TileType.WEALTH_FRIENDS,
            TileType.WEALTH_QUESTION,
            TileType.WEALTH_SKULL,
            TileType.WEALTH_SWEEP,
            TileType.WEALTH_ARMOR,
            TileType.WEALTH_HEART,
            TileType.WEALTH_LOCK,
            TileType.WEALTH_STARS
        ];
        maxHeight = createBitmapsForCategory(wealth, xStart, yOffset, spacingBetweenTiles);
        yOffset += maxHeight + spacingBetweenTiles;

        // Weapons row
        var weapons:Array<TileType> = [
            TileType.WEAPON_AXE,
            TileType.WEAPON_BLOODY_AXE,
            TileType.WEAPON_SWORD,
            TileType.WEAPON_BLOODY_SWORD
        ];
        maxHeight = createBitmapsForCategory(weapons, xStart, yOffset, spacingBetweenTiles);
        yOffset += maxHeight + spacingBetweenTiles;

        // Blood row
        var blood:Array<TileType> = [
            TileType.BLOOD_1,
            TileType.BLOOD_2,
            TileType.BLOOD_3,
            TileType.BLOOD_4,
            TileType.BLOOD_5
        ];
        maxHeight = createBitmapsForCategory(blood, xStart, yOffset, spacingBetweenTiles);
    }

    private function createBitmapsForCategory(tileTypes:Array<TileType>, xStart:Float, y:Float, spacing:Float):Float {
        var x = xStart;
        var maxHeight = 0.0;
        
        for (tileType in tileTypes) {
            final tile = ObjectsTilemapManager.instance.getTile(tileType);
            if (tile != null) {
                final tileWidth = tile.width;
                final tileHeight = tile.height;
                
                // Track the maximum height in this row
                if (tileHeight > maxHeight) {
                    maxHeight = tileHeight;
                }
                
                final bitmap = new Bitmap(tile, this);
                bitmap.setPosition(x, y);
                bitmaps.push(bitmap);
                
                // Move x by tile width plus spacing
                x += tileWidth + spacing;
            }
        }
        
        return maxHeight;
    }

    public function start():Void {
        trace("ObjectsTilemapTestScene started");
    }

    public function destroy():Void {
        trace("ObjectsTilemapTestScene destroyed");
    }

    public function customUpdate(dt:Float, fps:Float) {}
}