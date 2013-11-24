package com.astroberries.core.screens.mainmenu.sub.levels;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.ui.ImageTextButton;
import com.badlogic.gdx.scenes.scene2d.utils.Drawable;
import com.badlogic.gdx.scenes.scene2d.utils.TextureRegionDrawable;

import static com.astroberries.core.CastleGame.game;

public class CastleIcon extends ImageTextButton {

    public CastleIcon(int num, Texture button, Texture buttonPushed) {
        this(Integer.toString(num), button, buttonPushed);
    }

    public CastleIcon(Texture button, Texture buttonPushed) {
        this("", button, buttonPushed);
    }

    private CastleIcon(String num, Texture button, Texture buttonPushed) {
        super(num, new ImageTextButtonStyle(
                new TextureRegionDrawable(new TextureRegion(button)),
                new TextureRegionDrawable(new TextureRegion(buttonPushed)),
                null,
                game().getSkin().getFont("level-select-num-font")));
        getLabelCell().padTop(14 * game().getRatio() * SelectLevelTable.BUTTON_RATIO)
                      .padRight(12 * game().getRatio() * SelectLevelTable.BUTTON_RATIO);
    }
}
