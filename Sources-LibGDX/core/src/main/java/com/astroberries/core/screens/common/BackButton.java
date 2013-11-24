package com.astroberries.core.screens.common;

import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import static com.astroberries.core.CastleGame.game;

public class BackButton extends Actor {

    private final Texture button;
    private final Texture buttonPressed;
    private Texture active;

    public BackButton(final StateName backState) {
        button = new Texture(Gdx.files.internal("common/back_button.png"));
        button.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        buttonPressed = new Texture(Gdx.files.internal("common/back_button_tapped.png"));
        buttonPressed.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        active = button;
        float size = button.getHeight() * game().getRatio();
        setBounds(0, Gdx.graphics.getHeight() - size, size, size);
        addListener(new ClickListener() {
            @Override
            public boolean touchDown(InputEvent event, float x, float y, int pointer, int buttonInt) {
                active = buttonPressed;
                return true;
            }
            @Override
            public void touchUp(InputEvent event, float x, float y, int pointer, int buttonInt) {
                active = button;
                game().getStateMachine().transitionTo(backState);
            }
        });
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        batch.draw(active, getX(), getY(), getWidth(), getHeight());
    }
}
