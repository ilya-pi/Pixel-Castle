package com.astroberries.core.screens.game.ai;

import java.util.HashMap;
import java.util.Map;

public class AIFactory {
    private Map<String, AI> variants = new HashMap<>();


    public AIFactory() {
        AI oneDirection = new OneDirection();
        variants.put(oneDirection.getVariant(), oneDirection);
    }

    public AI getAi(String variant) {
        return variants.get(variant).getNew();
    }
}
