package com.astroberries.core.screens.win;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;

public class StarsActor extends Actor {

    private final TextureRegion star;


    public StarsActor(Texture star, float centerX, float centerY) {
        this.star = new TextureRegion(star);

        setSize(star.getWidth() * game().getRatio(), star.getHeight() * game().getRatio());
        float x = centerX - getWidth() / 2f;
        float y = centerY - getHeight() / 2f;

        setPosition(x, y);
        setOrigin(getWidth() / 2f, getHeight() / 2f);
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        batch.draw(star, getX(), getY(), getOriginX(), getOriginY(), getWidth(), getHeight(), getScaleX(), getScaleY(), getRotation());
    }
}
