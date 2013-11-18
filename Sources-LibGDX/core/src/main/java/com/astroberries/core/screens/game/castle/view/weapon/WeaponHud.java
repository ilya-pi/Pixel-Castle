package com.astroberries.core.screens.game.castle.view.weapon;

import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.screens.game.castle.CastleImpl;
import com.astroberries.core.state.StateName;
import com.astroberries.core.state.internal.GameState;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.Group;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.Touchable;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import static com.astroberries.core.CastleGame.game;

public class WeaponHud extends Group {

    private final StateName player;
    private boolean folded = true;
    private int active = 0;
    private WeaponButton[] buttons = new WeaponButton[3];

    public WeaponHud(Castle castle) {
        player = castle.getPlayer();
        setPosition(castle.getBiggestSide(), castle.getBiggestSide() / 2);
        buttons[0] = new WeaponButton("weapon1", new Vector2(0, 0), this, 0);
        buttons[1] = new WeaponButton("weapon2", new Vector2(12, 0), this, 1);
        buttons[2] = new WeaponButton("weapon3", new Vector2(24, 0), this, 2);
        buttons[0].setState(WeaponButton.State.VISIBLE);
        buttons[0].setTouchable(Touchable.enabled);
        buttons[1].setState(WeaponButton.State.INVISIBLE);
        buttons[1].setTouchable(Touchable.disabled);
        buttons[2].setState(WeaponButton.State.INVISIBLE);
        buttons[2].setTouchable(Touchable.disabled);
        for (WeaponButton button : buttons) {
            addActor(button);
        }
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        if (game().state() == player) {
            super.draw(batch, parentAlpha);
        }
    }

    public int getWeapon() {
        return active;
    }

    public void pushed(int num) {
        active = num;
        if (folded) {
            unfold(num);
        } else {
            fold(num);
        }
    }

    private void unfold(int num) {
        for (int i = 0; i < buttons.length; i++) {
            if (i == num) {
                buttons[i].setState(WeaponButton.State.PRESSED);
            } else {
                buttons[i].setState(WeaponButton.State.VISIBLE);
            }
            buttons[i].setTouchable(Touchable.enabled);
            buttons[i].unfold();
        }
        folded = false;
    }

    private void fold(int num) {
        for (int i = 0; i < buttons.length; i++) {
            if (i == num) {
                buttons[i].setState(WeaponButton.State.PRESSED);
                buttons[i].setTouchable(Touchable.enabled);
                removeActor(buttons[i]);
                addActor(buttons[i]);
            } else {
                buttons[i].setState(WeaponButton.State.VISIBLE);
                buttons[i].setTouchable(Touchable.disabled);
            }
            buttons[i].fold();
        }
        folded = true;
    }

}
