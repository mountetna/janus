import * as Redux from 'redux';

import JanusReducer from './janus-reducer';
import LastActionReducer from './last-action-reducer';

export default class JanusModel{

  constructor(){

    var janusReducer = new JanusReducer();
    var lastAction = new LastActionReducer();
    var reducer = Redux.combineReducers({

      'userInfo': janusReducer.reducer(),
      'lastAction': lastAction.reducer()
    });

    var defaultState = {

      'userInfo': {

        'userEmail': '',
        'authToken': '',
        'firstName': '',
        'lastName': '',
        'permissions': [],

        'masterPerms': false,

        'loginStatus': false,
        'loginError': false,
        'loginErrorMsg': 'Invalid sign in.'
      }
    };

    this.store = Redux.createStore(reducer, defaultState);
  }
}