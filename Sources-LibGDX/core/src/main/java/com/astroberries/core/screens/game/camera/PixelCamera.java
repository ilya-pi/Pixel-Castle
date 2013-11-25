package com.astroberries.core.screens.game.camera;

import com.astroberries.core.config.GlobalGameConfig;
import com.astroberries.core.screens.game.GameScreen;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;

import static com.astroberries.core.CastleGame.game;
import static com.astroberries.core.config.GlobalGameConfig.DEFAULT_ANIMATION_METHOD;

public class PixelCamera extends OrthographicCamera {

    private static float DEFAULT_TRANSITION_TIME = 1f; // seconds by default

    private float transitionCompleteTime = 0f;
    private float transitionTime = 0f;
    private Vector3 transitionStartPoint = null;
    private float transitionZoomStart = 0f;

    private CameraState state = CameraState.FREE;
    private CameraState beforePauseState = CameraState.FREE;
    private StateName stateOnFinish = null;
    private Vector2 finalCoords = null;

    private final GameScreen gameScreen;

    public static enum CameraState {
        OVERVIEW, BULLET, CASTLE1, CASTLE2,

        FREE, PAUSE
    }

    public PixelCamera(GameScreen gameScreen) {
        super();
        this.gameScreen = gameScreen;
    }

    public void to(CameraState target, Float transitionCompleteTime, StateName stateOnFinish) {
        Gdx.app.log("camera", target.toString());
        this.transitionStartPoint = new Vector3(position);
        this.transitionZoomStart = zoom;
        this.transitionTime = 0f;
        this.stateOnFinish = stateOnFinish;
        if (transitionCompleteTime != null) {
            this.transitionCompleteTime = transitionCompleteTime;
        } else {
            this.transitionCompleteTime = DEFAULT_TRANSITION_TIME;
        }

        state = target;

        switch (state) {
            case OVERVIEW:
                this.setToOrtho(false, gameScreen.levelWidth, gameScreen.viewPortHeight);
                break;
            case CASTLE1:
                finalCoords = new Vector2(gameScreen.castle1.getCenter().x, gameScreen.castle1.getCenter().y);
                break;
            case BULLET:
                break;
            case CASTLE2:
                finalCoords = new Vector2(gameScreen.castle2.getCenter().x, gameScreen.castle2.getCenter().y);
                break;
            case FREE:
                break;
        }

    }

    public void setFree() {
        state = CameraState.FREE;
    }

    public void pause() {
        beforePauseState = state;
        state = CameraState.PAUSE;
    }

    public void unpause() {
        state = beforePauseState;
    }

    @Override
    public void update() {
        if (state == CameraState.CASTLE1 || state == CameraState.CASTLE2) {
            transitionTime += Gdx.graphics.getDeltaTime();
            if (transitionTime > transitionCompleteTime) {
                position.x = finalCoords.x;
                position.y = finalCoords.y;
                zoom = GlobalGameConfig.LEVEL_ZOOM;
                if (stateOnFinish != null) {
                    game().getStateMachine().transitionTo(stateOnFinish);
                }
            } else {
                float transitionState = transitionTime / transitionCompleteTime;
                position.x = DEFAULT_ANIMATION_METHOD.apply(transitionStartPoint.x, finalCoords.x, transitionState);
                position.y = DEFAULT_ANIMATION_METHOD.apply(transitionStartPoint.y, finalCoords.y, transitionState);
                zoom = DEFAULT_ANIMATION_METHOD.apply(transitionZoomStart, GlobalGameConfig.LEVEL_ZOOM, transitionState);
            }
        } else if (state == CameraState.BULLET) {
            if (gameScreen.bullet != null) {
                position.y = gameScreen.bullet.getCoordinates().y;
                position.x = gameScreen.bullet.getCoordinates().x;
            }
        }

        limits();
        super.update();
    }

    private void limits() {
        if (this.position.y > gameScreen.levelHeight - (gameScreen.viewPortHeight / 2f) * this.zoom) {
            this.position.y = gameScreen.levelHeight - (gameScreen.viewPortHeight / 2f) * this.zoom;
        }
        if (position.y < (gameScreen.viewPortHeight / 2f) * this.zoom) {
            position.y = gameScreen.viewPortHeight / 2f * this.zoom;
        }
        if (this.position.x > gameScreen.levelWidth - (gameScreen.levelWidth / 2f) * this.zoom) {
            this.position.x = gameScreen.levelWidth - (gameScreen.levelWidth / 2f) * this.zoom;
        }
        if (this.position.x < gameScreen.levelWidth / 2f * this.zoom) {
            this.position.x = gameScreen.levelWidth / 2f * this.zoom;
        }
    }

}
