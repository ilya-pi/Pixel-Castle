package com.astroberries.core.screens.pvp;

import com.astroberries.core.screens.common.BlendBackgroundActor;
import com.astroberries.core.screens.win.StarsActor;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Image;
import com.badlogic.gdx.scenes.scene2d.ui.Table;

import static com.astroberries.core.CastleGame.game;
import static com.badlogic.gdx.scenes.scene2d.actions.Actions.forever;
import static com.badlogic.gdx.scenes.scene2d.actions.Actions.rotateBy;

public class PvpEndScreen  implements Screen {

    private final Stage stage;
    private final Texture toDispose;
    private final Texture smallStarTexture;
    private final Texture bigStarTexture;
    private final Image winnerImage;

    public PvpEndScreen(TextureRegion screenshot, TextureRegion castle1Pixmap, int healthPercent1, TextureRegion castle2Pixmap, int healthPercent2) {
        stage = new Stage();
        toDispose = castle1Pixmap.getTexture();
        Gdx.input.setInputProcessor(stage);
        Image castle1 = new Image(castle1Pixmap);
        Image castle2 = new Image(castle2Pixmap);
        int winner;
        if (healthPercent1 < healthPercent2) {
            winner = 2;
            winnerImage = castle2;
        } else {
            winner = 1;
            winnerImage = castle1;
        }
        Table table = new ButtonsTable(winner);
        table.debug();

        float padWidthCastle = 16 * 5 * game().getRatio();
        float maxCastleWidth = 180 * game().getRatio();
        float castleScale;
        if (castle1.getWidth() > castle2.getWidth()) {
            castleScale = maxCastleWidth / castle1.getWidth();
        } else {
            castleScale = maxCastleWidth / castle2.getWidth();
        }
        float yCastle;
        if (castle1.getHeight() > castle2.getHeight()) {
            yCastle = (Gdx.graphics.getHeight() + table.getPadBottom()) / 2 - castle1.getHeight() * castleScale / 2;
        } else {
            yCastle = (Gdx.graphics.getHeight() + table.getPadBottom()) / 2 - castle2.getHeight() * castleScale / 2;
        }
        castle1.setPosition(padWidthCastle, yCastle);
        castle1.setScale(castleScale);
        castle2.setPosition(Gdx.graphics.getWidth() - padWidthCastle - castle2.getWidth() * castleScale, yCastle);
        castle2.setScale(castleScale);

        smallStarTexture = new Texture(Gdx.files.internal("win/small_star.png"));
        bigStarTexture = new Texture(Gdx.files.internal("win/big_star.png"));
        float winnerCenterX = winnerImage.getX() + winnerImage.getWidth() * castleScale / 2;
        float winnerCenterY = winnerImage.getY() + winnerImage.getHeight() * castleScale /2;
        StarsActor bigStar = new StarsActor(bigStarTexture, winnerCenterX, winnerCenterY);
        StarsActor smallStar = new StarsActor(smallStarTexture, winnerCenterX, winnerCenterY);

        stage.addActor(new BlendBackgroundActor(screenshot));
        stage.addActor(bigStar);
        stage.addActor(smallStar);
        stage.addActor(castle1);
        stage.addActor(castle2);
        stage.addActor(table);

        bigStar.addAction(forever(rotateBy(360, 120)));
        smallStar.addAction(forever(rotateBy(360, 100)));
    }

    @Override
    public void render(float delta) {
        Gdx.gl.glClearColor(0.2f, 0.2f, 0.2f, 1); //todo: do we need it?
        Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);

        stage.act(delta);
        stage.draw();
        //Table.drawDebug(stage); //todo: remove
    }

    @Override
    public void resize(int width, int height) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void show() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void hide() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void pause() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void resume() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void dispose() {
        stage.dispose();
        toDispose.dispose();
        bigStarTexture.dispose();
        smallStarTexture.dispose();
    }
}
