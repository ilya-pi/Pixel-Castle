package com.astroberries.core.screens.game.touch;

import com.astroberries.core.screens.game.camera.PixelCamera;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.input.GestureDetector;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;

import static com.astroberries.core.CastleGame.game;

public class MoveAndZoomListener extends GestureDetector.GestureAdapter {

    private final PixelCamera camera;

    private float lastInitialDistance = 0;
    private float lastCameraZoom = 1;
    private float newCameraZoom = 1;
    private float scrollRatio = 0;


    public MoveAndZoomListener(PixelCamera camera) {
        this.camera = camera;
    }

    @Override
    public boolean touchDown(float x, float y, int pointer, int button) {
        Vector3 aimStart = new Vector3(x, y, 0);
        camera.unproject(aimStart);
        return false;
    }

    @Override
    public boolean pan(float x, float y, float deltaX, float deltaY) {
        if (game().state() != StateName.AIMING1 || game().state() != StateName.AIMING2) {
            camera.translate(-deltaX * camera.zoom * scrollRatio, deltaY * camera.zoom * scrollRatio);
            return true;
        }
        return false;
    }

    @Override
    public boolean panStop(float x, float y, int pointer, int button) {
        return false;
    }

    @Override
    public boolean zoom(float initialDistance, float distance) {
        if (game().state() == StateName.PLAYER1 || game().state() == StateName.PLAYER2) {
            if (initialDistance != lastInitialDistance) {
                //Gdx.app.log("camera", " " + initialDistance + " " + lastInitialDistance);
                lastInitialDistance = initialDistance;
                lastCameraZoom = camera.zoom;
            }
            newCameraZoom = lastCameraZoom * (initialDistance / distance);
            if (newCameraZoom > 1) {
                newCameraZoom = 1;
            } else if (newCameraZoom < 0.2) {
                newCameraZoom = 0.2f;
            }
            camera.zoom = newCameraZoom;
        }
        return false;
    }

    @Override
    public boolean pinch(Vector2 initialPointer1, Vector2 initialPointer2, Vector2 pointer1, Vector2 pointer2) {
        //todo: implement this method rather then zoom to let user drag and zoom at the same time
        return false;
    }

    public void setScrollRatio(float scrollRatio) {
        this.scrollRatio = scrollRatio;
    }
}
