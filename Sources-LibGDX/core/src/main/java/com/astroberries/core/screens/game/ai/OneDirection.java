package com.astroberries.core.screens.game.ai;

import com.astroberries.core.config.GameLevel;
import com.badlogic.gdx.math.MathUtils;

public class OneDirection implements AI {

    @Override
    public AI getNew() {
        return new OneDirection();
    }

    @Override
    public String getType() {
        return "oneDirection";
    }

    @Override
    public AIResp nextShoot(GameLevel level) {
        return new AIResp(level.getBullets()[0], 135 * MathUtils.degreesToRadians);
    }
}
