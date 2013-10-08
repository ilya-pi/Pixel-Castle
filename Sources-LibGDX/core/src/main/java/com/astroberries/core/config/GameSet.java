package com.astroberries.core.config;

import java.util.List;

public class GameSet {

    private String name;
    private int number;
    private List<GameLevel> levels;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public List<GameLevel> getLevels() {
        return levels;
    }

    public void setLevels(List<GameLevel> levels) {
        this.levels = levels;
    }
}
