package com.astroberries.core.screens.game.debug;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;

public class DebugActor extends Actor {
    private BitmapFont font = new BitmapFont(Gdx.files.internal("scene2d/ui_skin/default_font/default.fnt"), false);

    public DebugActor() {
        setPosition(10, 10);
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        font.draw(batch, "fps: " + Gdx.graphics.getFramesPerSecond(), 20, 30);
    }
}
