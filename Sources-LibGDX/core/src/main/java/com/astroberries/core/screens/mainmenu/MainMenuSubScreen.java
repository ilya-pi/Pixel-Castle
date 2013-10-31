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

public class MainMenuSubScreen extends AbstractSubScreen {

    public static final String TITLE_PNG = "title.png";
    public static final String PLAY_BUTTON_CAPTION = "Play";
    public static final String OPTIONS_BUTTON_CAPTION = "Options";
    private Table table = new Table();

    public MainMenuSubScreen(final Skin skin, final CastleGame game) {

        this.table.setFillParent(true);
        final Image title = new Image(new Texture(Gdx.files.internal(TITLE_PNG)));
        final TextButton playButton = new TextButton(PLAY_BUTTON_CAPTION, skin);
        final TextButton optionsButton = new TextButton(OPTIONS_BUTTON_CAPTION, skin);
        playButton.addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                game.getStateMachine().transitionTo(StateName.LEVEL_OVERVIEW);
            }
        });

        this.table.right().padRight(50);

        this.table.add(title).width(35 * 5).height(16 * 5).spaceBottom(100);
        this.table.row();
        this.table.add(playButton).width(100).pad(5);
        this.table.row();
        this.table.add(optionsButton).width(100).pad(5);
    }

    @Override
    public Table getTable() {
        return this.table;
    }
}
