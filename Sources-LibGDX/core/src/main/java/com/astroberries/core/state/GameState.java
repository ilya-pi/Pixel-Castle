package com.astroberries.core.state;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GameState {

    /**
     * filled once, as all the States are created, but can also support dynamic states
     * <p/>
     * Require to be able address States with type-safety check, by the name
     */
    private static volatile Map<GameStates, GameState> INVERSE_LOOKUP_DICTIONARY = new HashMap<GameStates, GameState>();

    public static GameState lookup(GameStates name) {
        return GameState.INVERSE_LOOKUP_DICTIONARY.get(name);
    }

    GameStates name;
    Map<GameStates, List<TransitionAction>> transitions;

    public GameState(GameStates name, Map<GameStates, List<TransitionAction>> transitions) {
        this.name = name;
        this.transitions = transitions;
        if (!GameState.INVERSE_LOOKUP_DICTIONARY.containsKey(name)) {
            GameState.INVERSE_LOOKUP_DICTIONARY.put(name, this);
        } else {
            throw new Error(String.format("State %s is being overwritten. Severe error", name.name()));
        }
    }

    void transitionTo(GameStates target) {
        if (!this.transitions.containsKey(target)){
            throw new Error(String.format("Transition %s -> %s doesn't exist. Severe error", this.name.name(), target.name()));
        }
        for (TransitionAction ta : this.transitions.get(target)) {
            ta.doAction();
        }
    }

    public static abstract class TransitionAction {
        protected abstract void doAction();
    }
}
