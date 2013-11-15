package com.astroberries.core.screens.game.castle.view;

import com.astroberries.core.screens.game.castle.Castle;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.Actor;

public class HealthActor extends Actor {

    private final BitmapFont font = new BitmapFont(Gdx.files.internal("arial-15.fnt"), false);

    private final Castle castle;

    public HealthActor(Castle castle) {
        this.castle = castle;
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        font.draw(batch, "HL  " + castle.getHealth(), castle.getBiggestSide(), 5);
    }
}
