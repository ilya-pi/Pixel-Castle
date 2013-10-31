package com.astroberries.core.state;

import com.astroberries.core.state.internal.GameState;
import com.astroberries.core.state.internal.StateMachineImpl;

import java.util.*;

public class StateMashineBuilder {

    private Map<StateName, GameState> states = new HashMap<>();

    private StateName tmpFromState = null;
    private StateName tmpToState = null;
    private Map<StateName, LinkedList<Transition>> tmpToStates = null;

    private static enum Operation {
        START, FROM, TO, WITH
    }
    private Operation lastOp = Operation.START;


    public StateMashineBuilder from(StateName name) {
        if (lastOp != Operation.START && lastOp != Operation.WITH) {
            throw new IllegalStateException("from .. (to .. with)+");
        }
        if (lastOp == Operation.WITH) {
            states.put(tmpFromState, new GameState(tmpFromState, tmpToStates));
        }
        tmpFromState = name;
        tmpToStates = new HashMap<>();
        lastOp = Operation.FROM;
        return this;
    }

    public StateMashineBuilder to(StateName name) {
        if (lastOp != Operation.FROM && lastOp != Operation.WITH) {
            throw new IllegalStateException("from .. (to .. with)+");
        }

        tmpToState = name;
        lastOp = Operation.TO;
        return this;
    }

    public StateMashineBuilder with(Transition ... transitions) {
        if (lastOp != Operation.TO) {
            throw new IllegalStateException("from .. (to .. with)+");
        }

        tmpToStates.put(tmpToState, new LinkedList<>(Arrays.asList(transitions)));
        lastOp = Operation.WITH;
        return this;
    }

    public StateMachine build() {
        if (lastOp != Operation.WITH) {
            throw new IllegalStateException("from .. (to .. with)+");
        }
        states.put(tmpFromState, new GameState(tmpFromState, tmpToStates));
        return new StateMachineImpl(StateName.NIL, states);
    }
}
