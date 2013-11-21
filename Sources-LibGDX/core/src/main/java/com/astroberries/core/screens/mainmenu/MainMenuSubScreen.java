package com.astroberries.core.screens.mainmenu;

import com.astroberries.core.CastleGame;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.Image;
import com.badlogic.gdx.scenes.scene2d.ui.Skin;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.ui.TextButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;
import com.astroberries.core.state.StateName;

import static com.astroberries.core.CastleGame.game;

public class MainMenuSubScreen extends AbstractSubScreen {

    public static final String PLAY_BUTTON_CAPTION = "Play";
    public static final String OPTIONS_BUTTON_CAPTION = "Options";
    private static final int defaultHeight = 480;
    private Table table = new Table();

    public MainMenuSubScreen(final Skin skin) {
        float ratio = game().getRatio();
        table.setFillParent(true);
        final Image title = new Image(new Texture(Gdx.files.internal("main/title.png")));
        final TextButton playButton = new TextButton(PLAY_BUTTON_CAPTION, skin);
        final TextButton optionsButton = new TextButton(OPTIONS_BUTTON_CAPTION, skin);
        playButton.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game().getStateMachine().transitionTo(StateName.LEVEL_OVERVIEW);
            }
        });

        table.right().padRight(120 * ratio).top().padTop(16 * 3.8f * ratio);

        table.add(title).width(35 * 12 * ratio).height(16 * 12 * ratio).spaceBottom(16 * 10.5f * ratio);
        table.row();
        table.add(playButton).width(35 * 7.5f * ratio).height(16 * 4.5f * ratio).spaceBottom(16 * 2.6f * ratio);
        table.row();
        table.add(optionsButton).width(35 * 7.5f * ratio).height(16 * 4.5f * ratio);
    }

    @Override
    public Table getTable() {
        return table;
    }
}
