package com.astroberries.core.screens.win;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;

public class WinBackgroundActor extends Actor {

    private static Color OVERLAY_COLOR = new Color(255.0f / 255, 255.0f / 255, 255.0f / 255, 60.0f / 255);
    private final TextureRegion screenshot;

    public WinBackgroundActor(TextureRegion screenshot) {
        this.screenshot = screenshot;
        setBounds(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        batch.draw(screenshot, 0, 0);
        batch.end();

        Gdx.gl.glEnable(GL10.GL_BLEND);
        Gdx.gl.glBlendFunc(GL10.GL_SRC_ALPHA, GL10.GL_ONE_MINUS_SRC_ALPHA);
        game().shapeRenderer.identity();
        game().shapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
        game().shapeRenderer.rect(0, 0, getWidth(), getHeight(), OVERLAY_COLOR, OVERLAY_COLOR, OVERLAY_COLOR, OVERLAY_COLOR);
        game().shapeRenderer.end();
        Gdx.gl.glDisable(GL10.GL_BLEND);

        batch.begin();
    }
}
