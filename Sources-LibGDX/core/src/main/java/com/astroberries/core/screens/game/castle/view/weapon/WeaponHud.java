package com.astroberries.core.screens.game.castle.view.weapon;

import com.astroberries.core.config.GameLevel;
import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.Group;
import com.badlogic.gdx.scenes.scene2d.Touchable;

import static com.astroberries.core.CastleGame.game;

public class WeaponHud extends Group {

    public static final String WEAPON_PREFIX = "weapon";
    public static final int BUTTON_OFFSET = 12;
    private final StateName player;
    private boolean folded = true;
    private int active = 0;
    private final WeaponButton[] buttons;

    public WeaponHud(Castle castle, GameLevel level) {
        player = castle.getPlayer();
        setPosition(castle.getBiggestSide(), castle.getBiggestSide() / 2);
        int[] bullets = level.getBullets();
        buttons = new WeaponButton[bullets.length];
        for (int i = 0; i < bullets.length; i++) {
            buttons[i] = new WeaponButton(WEAPON_PREFIX + bullets[i], new Vector2(i * BUTTON_OFFSET, 0), this, i);
            buttons[i].setState(WeaponButton.State.INVISIBLE);
            buttons[i].setTouchable(Touchable.disabled);
            addActor(buttons[i]);

        }
        buttons[0].setState(WeaponButton.State.VISIBLE);
        buttons[0].setTouchable(Touchable.enabled);
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
