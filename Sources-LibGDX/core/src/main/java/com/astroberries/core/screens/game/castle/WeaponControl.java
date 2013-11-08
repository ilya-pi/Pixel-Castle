package com.astroberries.core.screens.game.castle;

import com.astroberries.core.CastleGame;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.math.Vector3;
import com.badlogic.gdx.utils.Disposable;

public class WeaponControl implements Disposable {

    private final Texture weapon1;
    private final Texture weapon1pressed;
    private final Texture weapon2;
    private final Texture weapon2pressed;
    private final Texture weapon3;
    private final Texture weapon3pressed;
    private final Texture activeWeapon;
    private final Texture activeWeaponPressed;


    public WeaponControl() {
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

    public void render(float x, float y, CastleGame game, PixelCamera camera) {
        game.spriteBatch.begin();
        Vector3 projected = new Vector3(x, y, 0); //todo: redundant GC?
        camera.project(projected);
        game.spriteBatch.draw(activeWeapon, projected.x, projected.y, activeWeapon.getWidth(), activeWeapon.getHeight());
        game.spriteBatch.end();
    }

    @Override
    public void dispose() {
        //To change body of implemented methods use File | Settings | File Templates.
    }
}
