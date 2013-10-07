package com.astroberries.core.bullets;

import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.World;

public interface Bullet {

    public Vector2 getCoordinates();

    public void render(ShapeRenderer shapeRenderer);

    public void dispose();

    public boolean isAlive();

    void fire();
}
