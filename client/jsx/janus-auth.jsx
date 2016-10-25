import React from 'react';
import ReactDOM from 'react-dom';

import JanusUI from './components/janus-ui'

class JanusAuth{

  constructor(){

    this.buildUI();
  }

  buildUI(){

    var callbacks = {

      startLogin: this['startLogin'].bind(this)
    }

    ReactDOM.render(

      <JanusUI callbacks={ callbacks } />,
      document.getElementById('ui-group')
    );
  }

  startLogin(email, pass){

    //Serialize the request for POST
    var logItems = 'email='+ email +"&pass="+ pass;

    AJAX({

      url: './login',
      method: 'POST',
      sendType: 'serial',
      returnType: 'json',
      data: logItems,
      success: this['authorizationResponse'].bind(this),
      error: this['ajaxError'].bind(this)
    });
  }

  authorizationResponse(response){

    if(response['success']){

      console.log(response);
    }
    else{

      console.log('There was an error.');
    }
  }

  ajaxError(xhr, config, error){

    console.log(xhr, config, error);
  }
}

//Initilize the class.
var janusAuth = new JanusAuth();