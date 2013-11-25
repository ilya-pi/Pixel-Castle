package com.astroberries.core.screens.common;

import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.ImageButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;
import com.badlogic.gdx.scenes.scene2d.utils.Drawable;
import com.badlogic.gdx.scenes.scene2d.utils.TextureRegionDrawable;

import static com.astroberries.core.CastleGame.game;

public class ButtonFactory {

    private static final Texture backButton = new Texture(Gdx.files.internal("common/back_button.png"));
    private static final Texture backButtonPressed = new Texture(Gdx.files.internal("common/back_button_tapped.png"));
    private static final Texture pauseButton = new Texture(Gdx.files.internal("common/pause_button.png"));
    private static final Texture pauseButtonPressed = new Texture(Gdx.files.internal("common/pause_button_tapped.png"));
    private static final Texture playButton = new Texture(Gdx.files.internal("common/play_button.png"));
    private static final Texture playButtonPressed = new Texture(Gdx.files.internal("common/play_button_tapped.png"));

    public static ImageButton getBackButton(final StateName pushChangeState) {
        ImageButton imageButton = getButton(backButton, backButtonPressed, pushChangeState);
        imageButton.setPosition(0, Gdx.graphics.getHeight() - imageButton.getHeight());
        return imageButton;
    }

    public static ImageButton getPauseButton(final StateName pushChangeState) {
        ImageButton imageButton = getButton(pauseButton, pauseButtonPressed, pushChangeState);
        imageButton.setPosition(Gdx.graphics.getWidth() - imageButton.getWidth(), Gdx.graphics.getHeight() - imageButton.getHeight());
        return imageButton;
    }

    public static ImageButton getPlayButton() {
        ImageButton imageButton = getButton(playButton, playButtonPressed, null);
        imageButton.setPosition(Gdx.graphics.getWidth() - imageButton.getWidth(), Gdx.graphics.getHeight() - imageButton.getHeight());
        return imageButton;
    }

    private static ImageButton getButton(Texture button, Texture buttonPressed, final StateName pushChangeState) {
        button.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        buttonPressed.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        Drawable buttonDrawable = new TextureRegionDrawable(new TextureRegion(button));
        Drawable buttonPushedDrawable = new TextureRegionDrawable(new TextureRegion(buttonPressed));
        ImageButton imageButton = new ImageButton(buttonDrawable, buttonPushedDrawable);
        float height = button.getHeight() * game().getRatio();
        float width = button.getWidth() * game().getRatio();
        imageButton.setSize(width, height);
        if (pushChangeState != null) {
            imageButton.addListener(new ClickListener() {
                @Override
                public void clicked(InputEvent event, float x, float y) {
                    game().getStateMachine().transitionTo(pushChangeState);
                }
            });
        } else {
            imageButton.addListener(new ClickListener() {
                @Override
                public void clicked(InputEvent event, float x, float y) {
                    game().getStateMachine().transitionTo(game().getStateMachine().getPreviousState());
                }
            });
        }
        return imageButton;
    }


}
