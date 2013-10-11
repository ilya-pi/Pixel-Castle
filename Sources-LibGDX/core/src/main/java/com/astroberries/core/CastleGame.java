package com.astroberries.core;

import com.astroberries.core.screens.MainScreen;
import com.astroberries.core.screens.game.GameScreen;
import com.astroberries.core.state.GameState;
import com.astroberries.core.state.GameStateMachine;
import com.astroberries.core.state.GameStates;
import com.badlogic.gdx.Game;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;

import static com.astroberries.core.state.GameState.TransitionAction;
import static com.astroberries.core.state.util.MapUtils.asMap;
import static com.astroberries.core.state.util.MapUtils.e;
import static java.util.Arrays.asList;

public class CastleGame extends Game {


    public SpriteBatch spriteBatch;
    public ShapeRenderer shapeRenderer;

    private GameStateMachine stateMachine;

    private static CastleGame INSTANCE;

    public CastleGame() {
        super();
        CastleGame.INSTANCE = this;
    }

    @Override
    public void create() {
        spriteBatch = new SpriteBatch();
        shapeRenderer = new ShapeRenderer();
        Texture.setEnforcePotImages(false);
        this.stateMachine = initStateMachine();
        this.stateMachine.to(GameStates.MAINMENU);
    }

    private GameStateMachine initStateMachine() {
        TransitionAction nil2MainMenu = new TransitionAction() {
            @Override
            protected void doAction() {
                CastleGame.INSTANCE.setScreen(MainScreen.geCreate(CastleGame.INSTANCE));
            }
        };
        GameState nil = new GameState(GameStates.NIL,
                asMap(
                        e(GameStates.MAINMENU, asList(new TransitionAction[]{
                                nil2MainMenu
                        }))
                ));

        TransitionAction mainMenu2ChooseGame = new TransitionAction() {
            @Override
            protected void doAction() {
                System.out.println("type safety my ass ;D");
            }
        };
        TransitionAction mainMenu2SinglePlayer = new TransitionAction() {
            @Override
            protected void doAction() {
                //todo: here we should set level and set number (set is a group of levels displayed on screen)
                CastleGame.INSTANCE.setScreen(new GameScreen(CastleGame.INSTANCE, 0, 0));
                MainScreen.geCreate(CastleGame.INSTANCE).dispose();
            }
        };
        TransitionAction commonAction = new TransitionAction() {
            @Override
            protected void doAction() {
                System.out.println("an action that may be shared among the number of states");
            }
        };
        GameState mainMenu = new GameState(GameStates.MAINMENU,
                asMap(
                        e(GameStates.CHOOSE_GAME, asList(new TransitionAction[]{
                                mainMenu2ChooseGame, commonAction
                        })),
                        e(GameStates.SINGLE_PLAYER, asList(new TransitionAction[]{
                                mainMenu2SinglePlayer
                        }))
                ));

        return new GameStateMachine(nil);
    }

    @Override
    public void render() {
        super.render();
    }

    @Override
    public void dispose() {
        spriteBatch.dispose();
    }

    public GameStateMachine getStateMachine() {
        return stateMachine;
    }
}
