package com.astroberries.core.screens.game.castle.view.weapon;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Interpolation;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.Touchable;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import static com.badlogic.gdx.scenes.scene2d.actions.Actions.moveTo;

public class WeaponButton extends Actor {

    public static final int SIZE = 10;

    public enum State {
        VISIBLE, INVISIBLE, PRESSED
    }
    private final Texture button;
    private final Texture buttonPressed;
    private State state = State.INVISIBLE;
    private Texture active;
    private final Vector2 end;

    public WeaponButton(String fileName, Vector2 end, final WeaponHud hud, final int num) {
        this.end = end;
        button = new Texture(Gdx.files.internal("weapon_buttons/" + fileName + ".png"));
        button.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        buttonPressed = new Texture(Gdx.files.internal("weapon_buttons/" + fileName + "_pressed.png"));
        buttonPressed.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        setBounds(0, 0, SIZE, SIZE);
        addListener(new ClickListener() {
            @Override
            public boolean touchDown(InputEvent event, float x, float y, int pointer, int buttonInt) {
                Gdx.app.log("touch", "touchDown");
                setState(State.PRESSED);
                return true;
            }
            @Override
            public void touchUp(InputEvent event, float x, float y, int pointer, int buttonInt) {
                Gdx.app.log("touch", "touchUp");
                setState(State.VISIBLE);
                hud.pushed(num);
            }
        });
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        if (state != State.INVISIBLE) {
            batch.draw(active, getX(), getY(), SIZE, SIZE);
        }
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
        switch (state) {
            case VISIBLE:
                active = button;
                setTouchable(Touchable.enabled);
                break;
            case PRESSED:
                active = buttonPressed;
                break;
            case INVISIBLE:
                active = null;
        }
    }

    public void unfold() {
        addAction(moveTo(end.x, end.y, 0.4f, Interpolation.pow3));
    }

    public void fold() {
        addAction(moveTo(0, 0, 0.4f, Interpolation.pow3));
    }



}
