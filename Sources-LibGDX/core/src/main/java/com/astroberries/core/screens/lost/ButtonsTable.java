package com.astroberries.core.screens.lost;

import com.astroberries.core.CastleGame;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.ui.TextButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import static com.astroberries.core.CastleGame.game;

public class ButtonsTable extends Table {

    public ButtonsTable() {
        super(game().getSkin());
        float ratio = game().getRatio();
        setFillParent(true);
        final Label title = new Label("You lose!", game().getSkin(), CastleGame.HUGE_TITLE_WHITE_STYLE);
        final TextButton levelSelect = new TextButton("Level select", game().getSkin());
        final TextButton again = new TextButton("Try again", game().getSkin());
        levelSelect.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game().getStateMachine().transitionTo(StateName.LEVEL_SELECT);
            }
        });
        again.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game().getStateMachine().transitionTo(StateName.LEVEL_OVERVIEW);
            }
        });

        float padBottom = 16 * 4.5f * ratio;
        float buttonHeight = 16 * 4.5f * ratio;

        bottom().padBottom(padBottom);
        row();
        add(title).colspan(2).padBottom(16 * 18 * ratio);
        row();
        add(levelSelect).width(35 * 7.5f * ratio).height(buttonHeight).padRight(16 * 4 * ratio);
        add(again).width(35 * 7.5f * ratio).height(buttonHeight);
    }

}
