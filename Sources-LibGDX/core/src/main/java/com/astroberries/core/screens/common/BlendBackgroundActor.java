package com.astroberries.core.screens.common;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;

public class BlendBackgroundActor extends Actor {

    private Color overlayColor = new Color(255.0f / 255, 255.0f / 255, 255.0f / 255, 60.0f / 255);
    private final TextureRegion screenshot;

    public BlendBackgroundActor(TextureRegion screenshot) {
        this(screenshot, null);
    }

    public BlendBackgroundActor(TextureRegion screenshot, Color overlayColor) {
        this.screenshot = screenshot;
        if (overlayColor != null) {
            this.overlayColor = overlayColor;
        }
        setBounds(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

    }

    public BlendBackgroundActor() {
        this(null, null);
    }

    public BlendBackgroundActor(Color overlayColor) {
        this(null, overlayColor);
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        if (screenshot != null) {
            batch.draw(screenshot, 0, 0);
        }
        batch.end();

        Gdx.gl.glEnable(GL10.GL_BLEND);
        Gdx.gl.glBlendFunc(GL10.GL_SRC_ALPHA, GL10.GL_ONE_MINUS_SRC_ALPHA);
        game().fixedShapeRenderer.identity();
        game().fixedShapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
        game().fixedShapeRenderer.rect(0, 0, getWidth(), getHeight(), overlayColor, overlayColor, overlayColor, overlayColor);
        game().fixedShapeRenderer.end();
        Gdx.gl.glDisable(GL10.GL_BLEND);

        batch.begin();
    }
}
