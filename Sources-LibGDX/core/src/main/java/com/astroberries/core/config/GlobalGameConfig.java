package com.astroberries.core.config;

import com.badlogic.gdx.math.Interpolation;

public class GlobalGameConfig {

    /**
     * Time that the level overview is shown prior to zoom in on a certain castle
     */
    public static final long LEVEL_INTRO_TIMEOUT = 3000;

    /**
     * The most usable animation method in the game
     */
    public static final Interpolation DEFAULT_ANIMATION_METHOD = Interpolation.sineIn;

    /**
     * Zoom on castle focus, might be level specific in future
     */
    public static final float LEVEL_ZOOM = 0.4f;

}
