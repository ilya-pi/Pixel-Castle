package com.astroberries.core.screens.game.ai;

public interface AI {

    public AI getNew();
    public String getVariant();
    public float nextAngle();
}
