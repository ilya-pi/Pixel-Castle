package com.astroberries.core;

import com.astroberries.core.screens.mainmenu.MainScreen;
import com.astroberries.core.screens.game.GameScreen;
import com.badlogic.gdx.Game;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.astroberries.core.state.StateMachine;
import com.astroberries.core.state.StateMashineBuilder;
import com.astroberries.core.state.StateName;
import com.astroberries.core.state.Transition;

import static com.astroberries.core.state.StateName.*;

public class CastleGame extends Game {

    public SpriteBatch spriteBatch;
    public ShapeRenderer shapeRenderer;
    private GameScreen gameScreen;
    private StateMachine stateMachine;

    private final static CastleGame instance = new CastleGame();

    private CastleGame() {
        super();
    }

    public static CastleGame game() {
        return instance;
    }

    @Override
    public void create() {
        spriteBatch = new SpriteBatch();
        shapeRenderer = new ShapeRenderer();
        Texture.setEnforcePotImages(false);
        this.stateMachine = initStateMachine();
        this.stateMachine.transitionTo(StateName.MAINMENU);
    }

    private StateMachine initStateMachine() {
        Transition nilToMainMenu = new Transition() {
            @Override
            public void execute() {
                CastleGame.this.setScreen(new MainScreen(CastleGame.this));
            }
        };
        Transition mainMenuToChooseGame = new Transition() {
            @Override
            public void execute() {
            }
        };
        Transition createGameScreen = new Transition() {
            @Override
            public void execute() {
                //todo: here we should set level and set number (set is a group of levels displayed on screen)
                gameScreen = new GameScreen(0, 0);
                CastleGame.this.getScreen().dispose();
                CastleGame.this.setScreen(gameScreen);
            }
        };
        Transition mainMenuToOverview = new Transition() {
            @Override
            public void execute() {
                gameScreen.mainMenuToOverview();
            }
        };
        Transition toPlayer1 = new Transition() {
            @Override
            public void execute() {
                gameScreen.toPlayer1();
            }
        };
        Transition player1ToAiming1 = new Transition() {
            @Override
            public void execute() {
                gameScreen.player1ToAiming1();
            }
        };
        Transition aiming1ToBullet1 = new Transition() {
            @Override
            public void execute() {
                gameScreen.aiming1ToBullet1();
            }
        };
        Transition toPlayer2 = new Transition() {
            @Override
            public void execute() {
                gameScreen.toPlayer2();
            }
        };
        Transition player2ToAiming2 = new Transition() {
            @Override
            public void execute() {
                gameScreen.player2ToAiming2();
            }
        };
        Transition toBullet2 = new Transition() {
            @Override
            public void execute() {
                gameScreen.toBullet2();
            }
        };
        Transition player1lost = new Transition() {
            @Override
            public void execute() {
                Gdx.app.log("state", "Show win/lost screen! 1st lost.");
            }
        };
        Transition player2lost = new Transition() {
            @Override
            public void execute() {
                Gdx.app.log("state", "Show win/lost screen! 2nd lost.");
            }
        };
        Transition updateWind = new Transition() {
            @Override
            public void execute() {
                gameScreen.updateWind();
            }
        };
        Transition aiAimAndShoot = new Transition() {
            @Override
            public void execute() {
                gameScreen.aiAimAndShoot();
            }
        };
        Transition toComputer2 = new Transition() {
            @Override
            public void execute() {
                gameScreen.toComputer2();
            }
        };
        Transition setCameraFree = new Transition() {
            @Override
            public void execute() {
                gameScreen.setCameraFree();
            }
        };

          //PVP
/*        return new StateMashineBuilder()
                .from(NIL).to(MAINMENU).with(nilToMainMenu)
                .from(MAINMENU).to(CHOOSE_GAME).with(mainMenuToChooseGame)
                               .to(LEVEL_OVERVIEW).with(createGameScreen, mainMenuToOverview)

                .from(LEVEL_OVERVIEW).to(CAMERA_MOVING_TO_PLAYER_1).with(toPlayer1)
                .from(CAMERA_MOVING_TO_PLAYER_1).to(PLAYER1).with(updateWind, setCameraFree)
                .from(PLAYER1).to(AIMING1).with(player1ToAiming1)
                .from(AIMING1).to(BULLET1).with(aiming1ToBullet1)
                .from(BULLET1).to(CAMERA_MOVING_TO_PLAYER_2).with(toPlayer2)
                              .to(PLAYER_2_LOST).with(player2lost)
                              .to(PLAYER_1_LOST).with(player1lost)
                .from(CAMERA_MOVING_TO_PLAYER_2).to(PLAYER2).with(updateWind, setCameraFree)
                .from(PLAYER2).to(AIMING2).with(player2ToAiming2)
                .from(AIMING2).to(BULLET2).with(toBullet2)
                .from(BULLET2).to(CAMERA_MOVING_TO_PLAYER_1).with(toPlayer1)
                              .to(PLAYER_2_LOST).with(player2lost)
                              .to(PLAYER_1_LOST).with(player1lost)
                .build();*/

        //AI
        return new StateMashineBuilder()
        .from(NIL).to(MAINMENU).with(nilToMainMenu)
                .from(MAINMENU).to(CHOOSE_GAME).with(mainMenuToChooseGame)
                .to(LEVEL_OVERVIEW).with(createGameScreen, mainMenuToOverview)

                .from(LEVEL_OVERVIEW).to(CAMERA_MOVING_TO_PLAYER_1).with(toPlayer1)
                .from(CAMERA_MOVING_TO_PLAYER_1).to(PLAYER1).with(updateWind, setCameraFree)
                .from(PLAYER1).to(AIMING1).with(player1ToAiming1)
                .from(AIMING1).to(BULLET1).with(aiming1ToBullet1)
                .from(BULLET1).to(CAMERA_MOVING_TO_PLAYER_2).with(toComputer2)
                .to(PLAYER_2_LOST).with(player2lost)
                .to(PLAYER_1_LOST).with(player1lost)
                .from(CAMERA_MOVING_TO_PLAYER_2).to(COMPUTER2).with(updateWind, aiAimAndShoot)
                .from(COMPUTER2).to(BULLET2).with(toBullet2)
                .from(BULLET2).to(CAMERA_MOVING_TO_PLAYER_1).with(toPlayer1)
                .to(PLAYER_2_LOST).with(player2lost)
                .to(PLAYER_1_LOST).with(player1lost)
                .build();
    }

    @Override
    public void render() {
        super.render();
    }

    @Override
    public void dispose() {
        spriteBatch.dispose();
    }

    public StateMachine getStateMachine() {
        return stateMachine;
    }

    public StateName state() {
        return stateMachine.getCurrentState();
    }
}
