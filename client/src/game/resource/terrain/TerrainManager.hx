package game.resource.terrain;

import h2d.Object;
import game.mvp.view.entities.terrain.TerrainEntity;
import h2d.Tile;
import hxd.res.TiledMap.TiledMapData;

class TerrainManager {

    public final terrainArray:Array<TerrainEntity> = new Array();

    public function new(parent:h2d.Object) {
        final envAndGrassLayer = new h2d.Object(parent);
        final treesLayer = new h2d.Object(parent);
        final groundLayer = new h2d.Object(parent);

        final mapData:TiledMapData = haxe.Json.parse(hxd.Res.MAP.entry.getText());
        final tw = mapData.tilewidth;
        final th = mapData.tileheight;
        final mw = mapData.width;
        final mh = mapData.height;

        final terrainEnvTile = hxd.Res.terrain.TERRAIN_ENV_TILEMAP.toTile();
        final terrainEnvGroup = new h2d.TileGroup(terrainEnvTile, envAndGrassLayer);

        final tiles = [
            for(y in 0 ... Std.int(terrainEnvTile.height / th))
            for(x in 0 ... Std.int(terrainEnvTile.width / tw))
                terrainEnvTile.sub(x * tw, y * th, tw, th)
        ];

        // Draw backgorund as a group
        for(layer in mapData.layers) {
            // iterate on x and y
            for(y in 0 ... mh) for (x in 0 ... mw) {
                // get the tile id at the current position 
                final tid = layer.data[x + y * mw];
                // skip transparent tiles
                if (tid != 0) {
                    // add a tile to the TileGroup
                    if (layer.name == 'env' || layer.name == 'grass') {
                        terrainEnvGroup.add(x * tw, y * th, tiles[tid - 1]);
                    } else if (layer.name == 'trees') {
                        generateTree(treesLayer, tid, x * tw, y * th);
                    } else if (layer.name == 'ground') {
                        generateGround(groundLayer, tiles[tid - 1], x * tw, y * th);
                    }
                }
            }
        }
    }

    private function generateTree(parent:Object, tileId:Int, x:Int, y:Int) {
        var tile = hxd.Res.terrain.TERRAIN_TREE_1.toTile();

        if (tileId == 486)
            tile = hxd.Res.terrain.TERRAIN_TREE_2.toTile();
        if (tileId == 487)
            tile = hxd.Res.terrain.TERRAIN_TREE_3.toTile();
        if (tileId == 488) {
            tile = hxd.Res.terrain.TERRAIN_TREE_4.toTile();
        }

        final terrainEntity = new TerrainEntity(tile);
        parent.addChild(terrainEntity);
        terrainEntity.setPositionByTileCenter(x, y);
        terrainArray.push(terrainEntity);
    }

    private function generateGround(parent:h2d.Object, tile:Tile, x:Int, y:Int) {
        final terrainEntity = new TerrainEntity(tile);
        parent.addChild(terrainEntity);
        terrainEntity.setPositionByTileCenter(x, y);
        terrainArray.push(terrainEntity);
    }

}