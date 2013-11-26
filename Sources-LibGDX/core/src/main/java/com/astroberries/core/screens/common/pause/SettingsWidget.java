package com.astroberries.core.screens.common.pause;

import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Slider;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.utils.Drawable;

import static com.astroberries.core.CastleGame.game;

public class SettingsWidget extends Table {

    private static Color OVERLAY_COLOR = new Color(0f / 255, 0f / 255, 0f / 255, 66.0f / 255);

    public SettingsWidget() {
        //debug(); //todo: delete
        float ratio = game().getRatio();
        setBackground(game().getSkin().getDrawable("default-round"));

        padLeft(16 * 5 * ratio);
        padRight(16 * 5 * ratio);
        padTop(16 * 3 * ratio);
        padBottom(16 * 3 * ratio);
        float textCellWidth = 35 * 8 * ratio;
        float controlPadding = 16 * 4 * ratio;
        float controlCellWidth = textCellWidth - controlPadding;


        row().height(16 * 4.5f * ratio).padBottom(16 * 2 * ratio);
        Label musicVolumeLabel = new Label("BGM volume", game().getSkin());
        add(musicVolumeLabel).width(textCellWidth);
        Slider musicSlider = new Slider(0, 100, 1, false, game().getSkin(), "game-horizontal");
        add(musicSlider).width(controlCellWidth).padLeft(controlPadding);

        row().height(16 * 4.5f * ratio).padBottom(16 * 2 * ratio);
        Label sfxVolumeLabel = new Label("SFX volume", game().getSkin());
        add(sfxVolumeLabel).width(textCellWidth);
        Slider sfxSlider = new Slider(0, 100, 1, false, game().getSkin(), "game-horizontal");
        add(sfxSlider).width(controlCellWidth).padLeft(controlPadding);

        row().height(16 * 4.5f * ratio);
        Label vibration = new Label("Vibration", game().getSkin());
        add(vibration).width(textCellWidth);
        add().width(controlCellWidth).padLeft(controlPadding);
    }
}
