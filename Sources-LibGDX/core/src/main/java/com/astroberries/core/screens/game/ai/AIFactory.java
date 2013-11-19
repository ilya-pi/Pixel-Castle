package com.astroberries.core.screens.game.ai;

import com.astroberries.core.config.GameLevel;

import java.util.HashMap;
import java.util.Map;

public class AIFactory {

    private Map<String, AI> types = new HashMap<>();

    public AIFactory() {
        AI oneDirection = new OneDirection();
        types.put(oneDirection.getType(), oneDirection);
    }

    public AI getAi(String type) {
        return types.get(type).getNew();
    }
}
