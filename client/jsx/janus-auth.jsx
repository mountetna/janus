import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';

import JanusModel from './models/janus-model';
import JanusUIContainer from './components/janus-ui-container';

class JanusAuth{

  constructor(){

    this['model'] = null;

    this.initDataStore();
    this.checkLog();
    this.buildUI();
  }

  initDataStore(){

    this['model'] = new JanusModel();

    // Event hooks from the UI to the Controller
    this['model']['store'].subscribe(()=>{ 

      var lastAction = this['model']['store'].getState()['lastAction'];
      this.routeAction(lastAction);
    });
  }

  buildUI(){

    ReactDOM.render(

      <Provider store={ this['model']['store'] }>

        <JanusUIContainer />
      </Provider>,
      document.getElementById('ui-group')
    );
  }

  /*
   * Commands from the UI (via Redux).
   * You would normally see Thunk middleware implemented at the reducer for asyc
   * operations. However, since we are using web workers we don't care about 
   * asyc operations. We receive events from the redux store and we dispatch
   * events to the redux store. This way there is only one entry point to UI, 
   * which is through the redux store, and we do not upset the react/redux 
   * paradigm.
   */
  routeAction(action){

    switch(action['type']){

      case 'LOG_IN':

        this.logIn(action['data']['email'], action['data']['pass']);
        break;

      case 'LOG_OUT':

        this.logOut()
        break;
      default:

        //none
        break;
    }
  }

  checkLog(){

    if(COOKIES.hasItem(TOKEN_NAME)){

      //Serialize the request for POST
      var logItems = 'token='+ COOKIES.getItem(TOKEN_NAME);

      AJAX({

        url: '/check',
        method: 'POST',
        sendType: 'serial',
        returnType: 'json',
        data: logItems,
        success: this['checkLogResponse'].bind(this),
        error: this['ajaxError'].bind(this)
      });
    }
  }

  checkLogResponse(response){

    if(response['success'] && response['logged']){

      this.logInResponse(response);
    }
  }

  logIn(email, pass){

    //Serialize the request for POST
    var logItems = 'email='+ email +'&pass='+ pass;

    AJAX({

      url: './login',
      method: 'POST',
      sendType: 'serial',
      returnType: 'json',
      data: logItems,
      success: this['logInResponse'].bind(this),
      error: this['ajaxError'].bind(this)
    });
  }

  logInResponse(response){

    if(response['success']){

      //Set the token to the cookies so it may be used by multiple UI programs.
      COOKIES.setItem(TOKEN_NAME, response['user_info']['auth_token'], Infinity, '/', 'ucsf.edu');

      //Set the token to the local Redux store.
      var data = { 
        
        userEmail: response['user_info']['email'],
        authToken: response['user_info']['auth_token'],
        firstName: response['user_info']['first_name'],
        lastName: response['user_info']['last_name'],
      };
      var action = { type: 'LOGGED_IN', data: data };
    }
    else{

      var action = { type: 'LOG_ERROR' };
      console.log(response);
    }

    this['model']['store'].dispatch(action);
  }

  logOut(){

    var state = this['model']['store'].getState();
    var email = state['janusState']['userInfo']['userEmail'];
    var authToken = state['janusState']['userInfo']['authToken'];

    //Serialize the request for POST
    var logItems = 'email='+ email +'&token='+ authToken;

    AJAX({

      url: './logout',
      method: 'POST',
      sendType: 'serial',
      returnType: 'json',
      data: logItems,
      success: this['logOutResponse'].bind(this),
      error: this['ajaxError'].bind(this)
    });
  }

  logOutResponse(response){

    if(response['success'] && !response['logged']){

      COOKIES.removeItem(TOKEN_NAME);
      var action = { type: 'LOGGED_OUT' };
      this['model']['store'].dispatch(action);
    }
    else{

      var action = { type: 'LOG_ERROR' };
      console.log(response);
    }
  }

  ajaxError(xhr, config, error){

    console.log(xhr, config, error);
  }
}

//Initilize the class.
var janusAuth = new JanusAuth();