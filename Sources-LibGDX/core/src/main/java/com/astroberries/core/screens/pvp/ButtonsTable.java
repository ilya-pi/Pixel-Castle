package com.astroberries.core.screens.pvp;

import com.astroberries.core.CastleGame;
import com.astroberries.core.state.StateName;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.ui.TextButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import static com.astroberries.core.CastleGame.game;

public class ButtonsTable extends Table {

    public ButtonsTable(int winner) {
        super(game().getSkin());
        float ratio = game().getRatio();
        setFillParent(true);
        final Label titleFirstRow = new Label("Player " + Integer.toString(winner) , game().getSkin(), CastleGame.HUGE_TITLE_DARK_STYLE);
        final Label titleSecondRow = new Label("Wins!", game().getSkin(), CastleGame.HUGE_TITLE_DARK_STYLE);
        final TextButton mainMenu = new TextButton("Main menu", game().getSkin());
        final TextButton again = new TextButton("Play again", game().getSkin());
        mainMenu.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game().getStateMachine().transitionTo(StateName.MAINMENU);
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
        float bottomToButtonTop = padBottom + buttonHeight;

        bottom().padBottom(padBottom);
        row();
        add(titleFirstRow).colspan(2);
        row();
        add(titleSecondRow).colspan(2).padBottom(16 * 12 * ratio);
        row();
        add(mainMenu).width(35 * 7.5f * ratio).height(buttonHeight).padRight(16 * 4 * ratio);
        add(again).width(35 * 7.5f * ratio).height(buttonHeight);
    }
}