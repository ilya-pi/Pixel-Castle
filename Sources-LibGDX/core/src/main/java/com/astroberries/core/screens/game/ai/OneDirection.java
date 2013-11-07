package com.astroberries.core.screens.game.ai;

import com.badlogic.gdx.math.MathUtils;

public class OneDirection implements AI {

    @Override
    public AI getNew() {
        return new OneDirection();
    }

    @Override
    public String getVariant() {
        return "oneDirection";
    }

    @Override
    public float nextAngle() {
        return 135 * MathUtils.degreesToRadians;
    }
}
