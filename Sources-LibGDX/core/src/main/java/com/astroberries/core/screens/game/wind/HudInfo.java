package com.astroberries.core.screens.game.wind;

import com.badlogic.gdx.graphics.g2d.TextureRegion;

public class HudInfo {
    private final int strength;
    private final TextureRegion arrow;

    public HudInfo(int strength, TextureRegion arrow) {
        this.strength = strength;
        this.arrow = arrow;
    }

    public int getStrength() {
        return strength;
    }

    public TextureRegion getArrow() {
        return arrow;
    }
}
