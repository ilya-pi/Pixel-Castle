package com.astroberries.core.screens.game.background;

import com.astroberries.core.screens.game.camera.PixelCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.scenes.scene2d.Actor;

import static com.astroberries.core.CastleGame.game;

public class BackgroundActor extends Actor {

    private final Texture level;
    private final Texture background;
    private final Texture sky;
    private final PixelCamera camera;
    private final float levelWidth;

    public BackgroundActor(Texture level, Texture background, Texture sky, PixelCamera camera, float levelWidth) {
        this.level = level;
        this.background = background;
        this.sky = sky;
        this.camera = camera;
        this.levelWidth = levelWidth;
        setPosition(0, 0);
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        batch.draw(sky, camera.position.x * 0.6f - levelWidth / 2f * 0.6f, 0);
        batch.draw(background, camera.position.x * 0.4f - levelWidth / 2f * 0.4f, 0);
        batch.draw(level, 0, 0);
    }
}
