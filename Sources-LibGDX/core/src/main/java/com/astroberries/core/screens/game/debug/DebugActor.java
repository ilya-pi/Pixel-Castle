package com.astroberries.core.screens.game.debug;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;

public class DebugActor extends Actor {
    private BitmapFont font = new BitmapFont(Gdx.files.internal("arial-15.fnt"), false);

    public DebugActor() {
        setPosition(10, 10);
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        game().fixedBatch.begin();
        font.draw(game().fixedBatch, "fps: " + Gdx.graphics.getFramesPerSecond(), 20, 30);
        game().fixedBatch.end();
    }
}
