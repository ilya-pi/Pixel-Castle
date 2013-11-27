package com.astroberries.core.screens.mainmenu;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;
import static com.badlogic.gdx.scenes.scene2d.actions.Actions.*;

public class MenuBackgroundActor extends Actor {

    // Top overlay color
    private static Color COLOR_A = new Color(236.0f / 255, 0.0f / 255, 140.0f / 255, 150.0f / 255);
    // Bottom overlay color
    private static Color COLOR_B = new Color(134.0f / 255, 78.0f / 255, 113.0f / 255, 210.0f / 255); //todo: not quite sure about this color


    private final Texture texture;

    public MenuBackgroundActor(Texture texture, float width, float height) {
        this.texture = texture;
        setBounds(0, 0, width, height);
        addAction(forever(sequence(moveTo(0, 0, 0), moveTo(-width, 0, 10f))));
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        batch.draw(texture, getX(), getY(), getWidth(), getHeight());
        batch.draw(texture, getX() + getWidth(), getY(), getWidth(), getHeight());
        batch.end();

        Gdx.gl.glEnable(GL10.GL_BLEND);
        Gdx.gl.glBlendFunc(GL10.GL_SRC_ALPHA, GL10.GL_ONE_MINUS_SRC_ALPHA);
        game().fixedShapeRenderer.identity();
        game().fixedShapeRenderer.begin(ShapeRenderer.ShapeType.Filled);
        game().fixedShapeRenderer.rect(0, 0, getWidth(), getHeight(), COLOR_B, COLOR_B, COLOR_A, COLOR_A);
        game().fixedShapeRenderer.end();
        Gdx.gl.glDisable(GL10.GL_BLEND);

        batch.begin();
    }
}
