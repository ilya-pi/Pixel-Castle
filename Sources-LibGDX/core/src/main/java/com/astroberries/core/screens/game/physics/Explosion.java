package com.astroberries.core.screens.game.physics;

import com.badlogic.gdx.math.Vector2;

import java.util.ArrayList;
import java.util.List;

public class Explosion {

    private final List<Coordinate> particlesToCreate = new ArrayList<>(100);
    private final Vector2 speed;

    public Explosion(Vector2 speed) {
        this.speed = speed;
    }

    public List<Coordinate> getParticlesToCreate() {
        return particlesToCreate;
    }

    public Vector2 getSpeed() {
        return speed;
    }
}
