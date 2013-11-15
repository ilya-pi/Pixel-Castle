package com.astroberries.core.screens.game.castle;

import com.astroberries.core.screens.game.camera.PixelCamera;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.input.GestureDetector;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;
import com.badlogic.gdx.utils.Disposable;

import static com.astroberries.core.CastleGame.game;

public class WeaponControl implements Disposable {

    private final Texture weapon1;
    private final Texture weapon1pressed;
    private final Texture weapon2;
    private final Texture weapon2pressed;
    private final Texture weapon3;
    private final Texture weapon3pressed;
    private final Texture activeWeapon;
    private final Texture activeWeaponPressed;
    private final CastleGestureListener gestureListener;
    private volatile boolean touched = false;
    private CastleImpl.Location location;

    public final Vector2 topLeftTouch = new Vector2(-1000, -1000);
    public final Vector2 bottomRightTouch = new Vector2(-1000, -1000);
    public final Vector3 touch = new Vector3();

    public class CastleGestureListener extends GestureDetector.GestureAdapter {
        @Override
        public boolean touchDown(float x, float y, int pointer, int button) {
            touch.x = x;
            touch.y = Gdx.graphics.getHeight() - y;
            //Gdx.app.log("touch", location + " touchDown");
            if (isTouchInActiveArea(touch.x, touch.y)) {
                touched = true;
                return true;
            }
            return false;
        }
        @Override
        public boolean tap(float x, float y, int count, int button) {
            //Gdx.app.log("touch", location + " touchUp");
            touched = false;
            return false;
        }
        @Override
        public boolean pan(float x, float y, float deltaX, float deltaY) {
            //Gdx.app.log("touch", location + " pan");
            if (touched) {
                touched = false;
                return true;
            }
            return false;
        }
        @Override
        public boolean longPress(float x, float y) {
            //Gdx.app.log("touch", location + " longpress");
            if (touched) {
                touched = false;
                return true;
            }
            return false;
        }
        @Override
        public boolean fling(float velocityX, float velocityY, int button) {
            //Gdx.app.log("touch", location + " fling");
            if (touched) {
                touched = false;
                return true;
            }
            return false;
        }
        @Override
        public boolean panStop(float x, float y, int pointer, int button) {
            //Gdx.app.log("touch", location + " panstop");
            if (touched) {
                touched = false;
                return true;
            }
            return false;
        }
        @Override
        public boolean zoom(float initialDistance, float distance) {
            //Gdx.app.log("touch", " zoom");
            if (touched) {
                touched = false;
                return true;
            }
            return false;
        }
        @Override
        public boolean pinch(Vector2 initialPointer1, Vector2 initialPointer2, Vector2 pointer1, Vector2 pointer2) {
            //Gdx.app.log("touch", location + " pinch");
            if (touched) {
                touched = false;
                return true;
            }
            return false;
        }
    }

    public WeaponControl(CastleImpl.Location location) {
        this.location = location;
        gestureListener = new CastleGestureListener();
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

    public void render(float x, float y, PixelCamera camera) {
        game().spriteBatch.begin();
        Vector3 projected = new Vector3(x, y, 0); //todo: redundant GC?
        camera.project(projected);
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
        game().spriteBatch.end();
    }

    public boolean isTouchInActiveArea(float x, float y) {
/*
        Gdx.app.log("weapon", "x " + x + ", xleft " + topLeftTouch.x + ", xRight " + bottomRightTouch.x);
        Gdx.app.log("weapon", "y " + y + ", ytop " + topLeftTouch.y + ", yBottom " + bottomRightTouch.y);
*/
        if (x < topLeftTouch.x) {
            return false;
        }
        if (x > bottomRightTouch.x) {
            return false;
        }
        if (y < topLeftTouch.y) {
            return false;
        }
        if (y > bottomRightTouch.y) {
            return false;
        }
        return true;
    }

    @Override
    public void dispose() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    public CastleGestureListener getGestureListener() {
        return gestureListener;
    }
}
