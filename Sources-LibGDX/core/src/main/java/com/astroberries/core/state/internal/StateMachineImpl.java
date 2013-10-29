package com.astroberries.core.state.internal;

import com.astroberries.core.state.StateMachine;
import com.astroberries.core.state.StateName;
import com.astroberries.core.state.Transition;

import java.util.Map;

public class StateMachineImpl implements StateMachine {

    private StateName currentState;
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
        for (Transition transition : states.get(currentState).getTransitions(toState)) {
            transition.execute();
        }
        currentState = toState;
    }
}
