package com.astroberries.core.screens.game.wind;

import com.astroberries.core.config.GameLevel;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.World;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.utils.Disposable;

import java.util.*;

import static com.astroberries.core.CastleGame.game;

public class Wind extends Actor implements Disposable {

    public static final float SCREEN_W_BIGGER_THEN_HUD = 4;
    public static final int WIND_MULTIPLIER = 3;
    public static final int ALL_POSITIONS = 11;
    private final World world;
    private final GameLevel levelConf;
    private final Texture arrows;
    private final Texture windHud;

    private final float yHud;
    private final float yArrow;
    private final float xArrow;
    private final float hudHeight;
    private final float hudWidth;
    private final float arrowHeight;
    private final float arrowWidth;

    private final List<HudInfo> accessibleHuds = new ArrayList<>();

    private float strength = 0;
    private int representationPosition = 0;

    public Wind(World world, GameLevel levelConf) {
        this.world = world;
        this.levelConf = levelConf;
        arrows = new Texture(Gdx.files.internal("wind/arrows.png"));
        arrows.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);
        windHud = new Texture(Gdx.files.internal("wind/wind_hud.png"));
        windHud.setFilter(Texture.TextureFilter.Linear, Texture.TextureFilter.Linear);

        float scale = (Gdx.graphics.getWidth() / SCREEN_W_BIGGER_THEN_HUD) / windHud.getWidth();

        int arrowOriginHeight = arrows.getHeight() / ALL_POSITIONS;
        arrowHeight = arrowOriginHeight * scale;
        arrowWidth = arrows.getWidth() * scale;

        hudHeight = windHud.getHeight() * scale;
        hudWidth = windHud.getWidth() * scale;

        yHud = Gdx.graphics.getHeight() - hudHeight;
        yArrow = yHud + hudHeight / 2 - arrowHeight / 2 + 4 * scale;
        xArrow = 130 * scale;

        for (int position = 0; position < ALL_POSITIONS; position++) {
            String strength = levelConf.getWind().get(position);
            if (!strength.equals("*")) {
                HudInfo hudInfo = new HudInfo(Integer.parseInt(strength), new TextureRegion(arrows, 0, position * arrowOriginHeight, arrows.getWidth(), arrowOriginHeight));
                accessibleHuds.add(hudInfo);
            }
        }
        update();
    }

    @Override
    public void draw(SpriteBatch batch, float parentAlpha) {
        batch.draw(windHud, 0, yHud, hudWidth, hudHeight);
        batch.draw(accessibleHuds.get(representationPosition).getArrow(), xArrow, yArrow, arrowWidth, arrowHeight);
    }

    public void update() {
        representationPosition = MathUtils.random(accessibleHuds.size() - 1);
        //representationPosition = 10;
        strength = accessibleHuds.get(representationPosition).getStrength() * WIND_MULTIPLIER;
        world.setGravity(new Vector2(strength, world.getGravity().y));
    }

    @Override
    public void dispose() {
        //todo: implement
    }
}
