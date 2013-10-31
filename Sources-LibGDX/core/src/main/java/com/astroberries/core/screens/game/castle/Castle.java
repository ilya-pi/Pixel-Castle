package com.astroberries.core.screens.game.castle;

import com.astroberries.core.CastleGame;
import com.astroberries.core.config.GameCastle;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.astroberries.core.screens.game.physics.PhysicsManager;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.Vector2;

public class Castle {

    static final float CANNON_PADDING = 4;

    private final Vector2 cannon;
    private final Vector2 center;
    private final Pixmap castlePixmap;
    private final Location location;
    private int health = 0;
    private GameCastle castleConfig;
    private final BitmapFont font = new BitmapFont(Gdx.files.internal("arial-15.fnt"), false);

    public static enum Location {
        LEFT, RIGHT
    }

    public Castle(GameCastle castleConfig, int levelWidth, int levelHeight, Location location) {
        this.location = location;
        this.castleConfig = castleConfig;
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

    public void renderAim(float x, float y, CastleGame game, PixelCamera camera) {
        game.shapeRenderer.setProjectionMatrix(camera.combined);
        game.shapeRenderer.identity();
        game.shapeRenderer.begin(ShapeRenderer.ShapeType.Line);
        game.shapeRenderer.line(center.x, center.y, x, y, Color.CYAN, Color.BLACK);
        game.shapeRenderer.end();
    }

    public void renderHealth(CastleGame game, PixelCamera camera) {
        game.spriteBatch.setProjectionMatrix(camera.combined);
        game.spriteBatch.begin();
        font.draw(game.spriteBatch, "HL  " + health, cannon.x, cannon.y);
        game.spriteBatch.end();
    }

    public void recalculateHealth(PhysicsManager physicsManager) {
        Gdx.app.log("health", "health for " + location + " castle: " + health);
        health = physicsManager.calculateOpaquePixels(castleConfig.getX(), castleConfig.getY(), castlePixmap.getWidth(), castlePixmap.getHeight());
    }
}
