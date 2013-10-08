package com.astroberries.core.screens.game.bullets;

import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.Vector2;

public interface Bullet {

    public Vector2 getCoordinates();

    public void render(ShapeRenderer shapeRenderer);

    public void dispose();

    public boolean isAlive();

    void fire();
}
