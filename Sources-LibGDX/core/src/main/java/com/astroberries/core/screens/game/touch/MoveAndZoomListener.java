package com.astroberries.core.screens.game.touch;

import com.astroberries.core.CastleGame;
import com.astroberries.core.screens.game.GameScreen;
import com.astroberries.core.screens.game.camera.PixelCamera;
import com.astroberries.core.screens.game.castle.Castle;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.input.GestureDetector;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;

public class MoveAndZoomListener implements GestureDetector.GestureListener {

    private final PixelCamera camera;
    private final CastleGame game;
    private final Vector3 aimEnd;
    private final GameScreen gameScreen;

    private float lastInitialDistance = 0;
    private float lastCameraZoom = 1;
    private float newCameraZoom = 1;
    private float scrollRatio;


    public MoveAndZoomListener(PixelCamera camera, CastleGame game, Vector3 aimEnd, GameScreen gameScreen) {
        this.camera = camera;
        this.game = game;
        this.aimEnd = aimEnd;
        this.gameScreen = gameScreen;
        this.scrollRatio = gameScreen.scrollRatio;
    }

    @Override
    public boolean touchDown(float x, float y, int pointer, int button) {
        Vector3 aimStart = new Vector3(x, y, 0);
        camera.unproject(aimStart);
        if (game.getStateMachine().getCurrentState() == StateName.PLAYER1 && gameScreen.castle1.isInsideAimArea(aimStart.x, aimStart.y)) {
            game.getStateMachine().transitionTo(StateName.AIMING1);
            aimEnd.x = aimStart.x;
            aimEnd.y = aimStart.y;

            return true;
        }
        if (game.getStateMachine().getCurrentState() == StateName.PLAYER2 && gameScreen.castle2.isInsideAimArea(aimStart.x, aimStart.y)) {
            game.getStateMachine().transitionTo(StateName.AIMING2);
            aimEnd.x = aimStart.x;
            aimEnd.y = aimStart.y;
            return false;
        }

        return false;
    }

    @Override
    public boolean tap(float x, float y, int count, int button) {
        return false;
    }

    @Override
    public boolean longPress(float x, float y) {
        return false;
    }

    @Override
    public boolean fling(float velocityX, float velocityY, int button) {
        return false;
    }

    @Override
    public boolean pan(float x, float y, float deltaX, float deltaY) {
        //Gdx.app.log("camera", " " + deltaX + " " + deltaY);
        if (game.getStateMachine().getCurrentState() == StateName.AIMING1 || game.getStateMachine().getCurrentState() == StateName.AIMING2) {
            aimEnd.x = x + deltaX;
            aimEnd.y = y + deltaY;
            //Gdx.app.log("touches", "pan " + unprojectedEnd.x + " " + unprojectedEnd.y);
            camera.unproject(aimEnd);
            return true;
        } else {
            camera.translate(-deltaX * camera.zoom * scrollRatio, deltaY * camera.zoom * scrollRatio);
            return true;
        }
    }

    @Override
    public boolean panStop(float x, float y, int pointer, int button) {
        if (game.getStateMachine().getCurrentState() == StateName.AIMING1 || game.getStateMachine().getCurrentState() == StateName.AIMING2) {
            gameScreen.fire(x, y);
            return true;
        }
        return false;
    }

    @Override
    public boolean zoom(float initialDistance, float distance) {
        if (game.getStateMachine().getCurrentState() == StateName.PLAYER1 || game.getStateMachine().getCurrentState() == StateName.PLAYER2) {
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
            return true;
        }
        return false;
    }

    @Override
    public boolean pinch(Vector2 initialPointer1, Vector2 initialPointer2, Vector2 pointer1, Vector2 pointer2) {
        //todo: implement this method rather then zoom to let user drag and zoom at the same time
        return false;
    }
}
