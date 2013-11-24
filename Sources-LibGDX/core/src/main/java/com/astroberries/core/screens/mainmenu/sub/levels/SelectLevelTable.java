package com.astroberries.core.screens.mainmenu.sub.levels;

import com.astroberries.core.CastleGame;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import static com.astroberries.core.CastleGame.game;

public class SelectLevelTable extends Table {

    public static final float INITIAL_BUTTON_SIZE = 210;
    public static final float CURRENT_BUTTON_SIZE = 180;
    public static final float BUTTON_RATIO = CURRENT_BUTTON_SIZE / INITIAL_BUTTON_SIZE;

    public static final int TOTAL_LEVELS = 6;
    public static final int COLUMNS = 3;

    public SelectLevelTable() {
        setFillParent(true);
        float ratio = game().getRatio();

        final Label title = new Label("Level select", game().getSkin(), CastleGame.TITLE_WHITE_STYLE);
        top();
        add(title).padTop(52 * ratio).colspan(COLUMNS).padBottom(46 * ratio);
        CastleImageHolder imageHolder = new CastleImageHolder();

        for (int i = 0; i < TOTAL_LEVELS; i++) {
            if (i % COLUMNS == 0) {
                row();
            }

            if (i <= 2 ) {
                CastleIcon castleIcon = new CastleIcon(i + 1, imageHolder.getAccomplished(), imageHolder.getAccomplishedPushed());
                castleIcon.addListener(new ClickListener() {
                    @Override
                    public void clicked(InputEvent event, float x, float y) {
                        game().getStateMachine().transitionTo(StateName.LEVEL_OVERVIEW);
                    }
                });
                add(castleIcon).width(CURRENT_BUTTON_SIZE * ratio).height(CURRENT_BUTTON_SIZE * ratio)
                               .pad(20 * ratio, 30 * ratio, 20 * ratio, 30 * ratio);
            } else if (i == 3 ) {
                add(new CastleIcon(i + 1, imageHolder.getCurrent(), imageHolder.getCurrentPushed()))
                        .width(CURRENT_BUTTON_SIZE * ratio).height(CURRENT_BUTTON_SIZE * ratio)
                        .pad(20 * ratio, 30 * ratio, 20 * ratio, 30 * ratio);
            } else {
                add(new CastleIcon(imageHolder.getLocked(), imageHolder.getLockedPushed()))
                        .width(CURRENT_BUTTON_SIZE * ratio).height(CURRENT_BUTTON_SIZE * ratio)
                        .pad(20 * ratio, 30 * ratio, 20 * ratio, 30 * ratio);
            }
        }
    }
}
