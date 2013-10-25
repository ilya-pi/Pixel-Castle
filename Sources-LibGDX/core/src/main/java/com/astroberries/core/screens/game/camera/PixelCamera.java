package com.astroberries.core.screens.game.camera;

import com.astroberries.core.config.GlobalGameConfig;
import com.astroberries.core.screens.game.GameScreen;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.math.Vector3;

import static com.astroberries.core.config.GlobalGameConfig.DEFAULT_ANIMATION_METHOD;

public class PixelCamera extends OrthographicCamera {

    private static float DEFAULT_TRANSITION_TIME = 3f; //three seconds by default

    private float transitionCompleteTime = 0f;
    private float transitionTime = 0f;
    private Vector3 transitionStartPoint = null;
    private float transitionZoomStart = 0f;

    private CameraState state = CameraState.FREE;

    public static enum CameraState {
        OVERVIEW, CASTLE1, BULLET, CASTLE2,

        FREE
    }

    public PixelCamera() {
        super();
    }

    public void to(CameraState target, Float _transitionCompleteTime) {
        this.transitionStartPoint = this.position;
        this.transitionZoomStart = this.zoom;
        this.transitionTime = 0f;
        if (_transitionCompleteTime != null) {
            transitionCompleteTime = _transitionCompleteTime;
        } else {
            transitionCompleteTime = DEFAULT_TRANSITION_TIME;
        }

        switch (state) {
            case OVERVIEW:
                this.setToOrtho(false, GameScreen.geCreate().levelWidth, GameScreen.geCreate().viewPortHeight);
                break;
            case CASTLE1:
            case BULLET:
                break;
            case CASTLE2:
                break;
            case FREE:
                break;
        }

        this.state = target;
    }

    public void setFree() {
        this.state = CameraState.FREE;
    }

    public void handle() {
        GameScreen gameScreen = GameScreen.geCreate();
        switch (state) {
            case OVERVIEW:
                break;
            case CASTLE1:
                transitionTime += Gdx.graphics.getDeltaTime();

                if (transitionTime > transitionCompleteTime) {
                    this.position.x = GameScreen.geCreate().castle1.getCenter().x;
                    this.position.y = GameScreen.geCreate().castle1.getCenter().y;
                    this.zoom = GlobalGameConfig.LEVEL_ZOOM;
                    this.setFree();
                } else {
                    this.position.x = DEFAULT_ANIMATION_METHOD.apply(this.transitionStartPoint.x,
                            gameScreen.castle1.getCenter().x, (transitionTime / transitionCompleteTime));
                    this.position.y = DEFAULT_ANIMATION_METHOD.apply(this.transitionStartPoint.y,
                            gameScreen.castle1.getCenter().y, (transitionTime / transitionCompleteTime));
                    this.zoom = DEFAULT_ANIMATION_METHOD.apply(this.transitionZoomStart,
                            GlobalGameConfig.LEVEL_ZOOM, (transitionTime / transitionCompleteTime));
                }
                break;
            case BULLET:
                if (gameScreen.bullet != null) {
                    this.position.y = gameScreen.bullet.getCoordinates().y;
                    this.position.x = gameScreen.bullet.getCoordinates().x;
                }
                break;
            case CASTLE2:
                break;
            case FREE:
                break;
        }

        limits();

        this.update();
    }

    private void limits() {
        GameScreen gameScreen = GameScreen.geCreate();
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
