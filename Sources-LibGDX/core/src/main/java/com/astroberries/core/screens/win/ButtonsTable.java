package com.astroberries.core.screens.win;

import com.astroberries.core.CastleGame;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.ui.TextButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import static com.astroberries.core.CastleGame.game;

public class ButtonsTable extends Table {

    private final float bottomToButtonTop;

    public ButtonsTable() {
        super(game().getSkin());
        float ratio = game().getRatio();
        setFillParent(true);
        final Label titleFirstRow = new Label("LEVEL", game().getSkin(), CastleGame.HUGE_TITLE_DARK_STYLE);
        final Label titleSecondRow = new Label("CLEAR!", game().getSkin(), CastleGame.HUGE_TITLE_DARK_STYLE);
        final TextButton levelSelect = new TextButton("Level select", game().getSkin());
        final TextButton nextLevel = new TextButton("Next level", game().getSkin());
        levelSelect.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game().getStateMachine().transitionTo(StateName.LEVEL_SELECT);
            }
        });
        nextLevel.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game().getStateMachine().transitionTo(StateName.LEVEL_OVERVIEW); //todo: set next level in gameScreen
            }
        });

        float padBottom = 16 * 4.5f * ratio;
        float buttonHeight = 16 * 4.5f * ratio;
        bottomToButtonTop = padBottom + buttonHeight;

        bottom().padBottom(padBottom);
        row();
        add(titleFirstRow).colspan(2);
        row();
        add(titleSecondRow).colspan(2).padBottom(16 * 12 * ratio);
        row();
        add(levelSelect).width(35 * 7.5f * ratio).height(buttonHeight).padRight(16 * 4 * ratio);
        add(nextLevel).width(35 * 7.5f * ratio).height(buttonHeight);
    }

    public float getBottomToButtonTop() {
        return bottomToButtonTop;
    }
}
