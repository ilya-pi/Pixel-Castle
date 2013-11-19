package com.astroberries.core.screens.game.ai;

import com.astroberries.core.config.GameLevel;

public interface AI {

    public AI getNew();
    public String getType();
    public AIResp nextShoot(GameLevel level);
}
