package com.astroberries.core.screens.game.bullet;

import com.badlogic.gdx.math.Vector2;

public interface Bullet {

    public Vector2 getCoordinates();

    public void render();

    public void dispose();

    public boolean isAlive();

    void fire();
}
