package com.astroberries.core.screens.game.castle;

import com.astroberries.core.CastleGame;
import com.astroberries.core.config.GameCastle;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.astroberries.core.screens.game.physics.PhysicsManager;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;

public class Castle {

    public static final float CANNON_PADDING = 4;
    private static final Color AIM_BUTTON_COLOR = new Color(0, 0, 1, 0.1f);
    public final float touchSide;
    public final Vector2 topLeftTouch;
    public final Vector2 bottomRightTouch;

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
        touchSide = Math.max(castlePixmap.getHeight(), castlePixmap.getWidth());

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
        topLeftTouch = new Vector2(center.x - touchSide/2, center.y - touchSide/2);
        bottomRightTouch = new Vector2(center.x + touchSide/2, center.y + touchSide/2);
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
        game.shapeRenderer.line(cannon.x, cannon.y, x, y, Color.CYAN, Color.BLACK);
        game.shapeRenderer.end();
    }

    public void renderHealth(CastleGame game, PixelCamera camera) {
        game.spriteBatch.begin();
        Vector3 projected = new Vector3(cannon.x, cannon.y, 0); //todo: redundant GC?
        camera.project(projected);
        font.draw(game.spriteBatch, "HL  " + health, projected.x, projected.y);
        game.spriteBatch.end();
    }

    public void renderAimButton(CastleGame game, PixelCamera camera) {
        Gdx.gl.glEnable(GL10.GL_BLEND);
        Gdx.gl.glBlendFunc(GL10.GL_SRC_ALPHA, GL10.GL_ONE_MINUS_SRC_ALPHA);
        game.shapeRenderer.setProjectionMatrix(camera.combined);
        game.shapeRenderer.identity();
        game.shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
        game.shapeRenderer.setColor(AIM_BUTTON_COLOR);
        game.shapeRenderer.rect(topLeftTouch.x, topLeftTouch.y, touchSide, touchSide);
        game.shapeRenderer.end();
        Gdx.gl.glDisable(GL10.GL_BLEND);
    }

    public void recalculateHealth(PhysicsManager physicsManager) {
        Gdx.app.log("health", "health for " + location + " castle: " + health);
        health = physicsManager.calculateOpaquePixels(castleConfig.getX(), castleConfig.getY(), castlePixmap.getWidth(), castlePixmap.getHeight());
    }

    public boolean isInsideAimArea(float x, float y) {
        if (x < topLeftTouch.x) {
            return false;
        }
        if (x > bottomRightTouch.x) {
            return false;
        }
        if (y < topLeftTouch.y) {
            return false;
        }
        if (y > bottomRightTouch.y) {
            return false;
        }
        return true;
    }
}
