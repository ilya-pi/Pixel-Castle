package com.astroberries.core.config;

import java.util.List;

public class GameLevel {

    private String name;
    private String path;
    private int number;
    private int velocity;
    private GameCastle castle1;
    private GameCastle castle2;
    private List<String> wind;
    private String aiVariant;
    private int[] bullets;

    public int[] getBullets() {
        return bullets;
    }

    public void setBullets(int[] bullets) {
        this.bullets = bullets;
    }

    public int getVelocity() {
        return velocity;
    }

    public void setVelocity(int velocity) {
        this.velocity = velocity;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }


    public void setName(String name) {
        this.name = name;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public void setCastle1(GameCastle castle1) {
        this.castle1 = castle1;
    }

    public void setCastle2(GameCastle castle2) {
        this.castle2 = castle2;
    }

    public String getName() {

        return name;
    }

    public int getNumber() {
        return number;
    }

    public GameCastle getCastle1() {
        return castle1;
    }

    public GameCastle getCastle2() {
        return castle2;
    }

    public List<String> getWind() {
        return wind;
    }

    public void setWind(List<String> wind) {
        this.wind = wind;
    }

    public String getAiVariant() {
        return aiVariant;
    }

    public void setAiVariant(String aiVariant) {
        this.aiVariant = aiVariant;
    }
}
