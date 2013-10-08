package com.astroberries.core.config;

import java.util.List;

public class GameConfig {
    List<GameSet> sets;

    public void setSets(List<GameSet> sets) {
        this.sets = sets;
    }

    public List<GameSet> getSets() {
        return sets;
    }
}
