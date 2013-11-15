package com.astroberries.core.screens.game.castle.view;

import com.astroberries.core.screens.game.castle.CastleImpl;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;
import com.badlogic.gdx.scenes.scene2d.Actor;

public class WeaponHudActor extends Actor {

    private final Texture weapon1;
    private final Texture weapon1pressed;
    private final Texture weapon2;
    private final Texture weapon2pressed;
    private final Texture weapon3;
    private final Texture weapon3pressed;
    private final Texture activeWeapon;
    private final Texture activeWeaponPressed;
    private volatile boolean touched = false;
    private CastleImpl.Location location;

    public final Vector2 topLeftTouch = new Vector2(-1000, -1000);
    public final Vector2 bottomRightTouch = new Vector2(-1000, -1000);
    public final Vector3 touch = new Vector3();

    public WeaponHudActor() {
        this.location = location;
        weapon1 = new Texture(Gdx.files.internal("weapon_buttons/weapon1.png"));
        weapon1.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        weapon1pressed = new Texture(Gdx.files.internal("weapon_buttons/weapon1_pressed.png"));
        weapon1pressed.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        weapon2 = new Texture(Gdx.files.internal("weapon_buttons/weapon2.png"));
        weapon2.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        weapon2pressed = new Texture(Gdx.files.internal("weapon_buttons/weapon2_pressed.png"));
        weapon2pressed.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        weapon3 = new Texture(Gdx.files.internal("weapon_buttons/weapon3.png"));
        weapon3.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        weapon3pressed = new Texture(Gdx.files.internal("weapon_buttons/weapon3_pressed.png"));
        weapon3pressed.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        activeWeapon = weapon1;
        activeWeaponPressed = weapon1pressed;
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
/*        game().spriteBatch.begin();
        topLeftTouch.x = projected.x;
        topLeftTouch.y = projected.y;
        bottomRightTouch.x = projected.x + activeWeapon.getWidth();
        bottomRightTouch.y = projected.y + activeWeapon.getHeight();
        if (touched) {
            //Gdx.app.log("weapon", "touched");
            game().spriteBatch.draw(activeWeaponPressed, projected.x, projected.y, activeWeapon.getWidth(), activeWeapon.getHeight());
        } else {
            //Gdx.app.log("weapon", "not touched");
            game().spriteBatch.draw(activeWeapon, projected.x, projected.y, activeWeapon.getWidth(), activeWeapon.getHeight());
        }
        game().spriteBatch.end();*/
    }
}
