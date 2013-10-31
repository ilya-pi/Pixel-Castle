package com.astroberries.core.screens.game.castle;

import com.astroberries.core.config.GameCastle;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.math.Vector2;

public class Castle {

    static final float CANNON_PADDING = 4;

    private final Vector2 cannon;
    private final Vector2 center;
    private final Pixmap castlePixmap;

    public static enum Location {
        LEFT, RIGHT
    }

    public Castle(GameCastle castleConfig, int levelWidth, int levelHeight, Location location) {
        castlePixmap = new Pixmap(Gdx.files.internal("castles/" + castleConfig.getImage()));

        float cannonY = levelHeight - (castleConfig.getY() - castlePixmap.getHeight()) + CANNON_PADDING;
        float cannonX;
        if (location == Location.LEFT) {
            cannonX = castleConfig.getX() + castlePixmap.getWidth() + CANNON_PADDING;
        } else {
            cannonX = castleConfig.getX() - CANNON_PADDING;
        }

        float centerX = castleConfig.getX() + castlePixmap.getWidth() / 2;
        float centerY = levelHeight - (castleConfig.getY() - castlePixmap.getHeight() / 2);

        cannon = new Vector2(cannonX, cannonY);
        center = new Vector2(centerX, centerY);
    }

    public Vector2 getCannon() {
        return cannon;
    }

    public Vector2 getCenter() {
        return center;
    }

    public Pixmap getCastlePixmap() {
        return castlePixmap;
    }
}
