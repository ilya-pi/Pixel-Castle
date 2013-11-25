package com.astroberries.core.state.internal;

import com.astroberries.core.state.StateMachine;
import com.astroberries.core.state.StateName;
import com.astroberries.core.state.Transition;
import com.badlogic.gdx.Gdx;

import java.util.Map;

public class StateMachineImpl implements StateMachine {

    private volatile StateName currentState;
    private volatile StateName previousState;
    private Map<StateName, GameState> states;

    public StateMachineImpl(StateName currentState, Map<StateName, GameState> states) {
        this.currentState = currentState;
        this.states = states;
    }

    @Override
    public void addState(GameState state) {
        if (states.containsKey(state.getName())) {
            throw new IllegalStateException("states set already contains state: " + state);
        }
        states.put(state.getName(), state);
    }

    @Override
    public StateName getCurrentState() {
        return currentState;
    }

    @Override
    public void transitionTo(StateName toState) {
        if (!states.get(currentState).isToStateExist(toState)) {
            throw new IllegalStateException("state from: " + currentState + " doesn't have state to: " + toState);
        }
        Gdx.app.log("states", "currentState: " + currentState + ", toState: " + toState);
        previousState = currentState;
        currentState = toState;
        for (Transition transition : states.get(previousState).getTransitions(toState)) {
            Gdx.app.log("states", "transition execute");
            transition.execute();
        }
    }

    @Override
    public StateName getPreviousState() {
        return previousState;
    }


}
