import * as React from 'react'

export default class LoginPanel extends React.Component{

  constructor(){

    super();
  }

  parseError(){

    if(this['props']['janusState']['loginError']){

      return { display: 'block' };
    }
    else{

      return { display: 'none' };
    }
  }

  startLogin(){

    var userEmail = document.getElementById('email-input').value;
    var userPass = document.getElementById('pass-input').value;
    this['props'].startLogin(userEmail, userPass);
  }

  render(){

    return (

      <div id='login-group'>

        <input id='email-input' className='log-input' type='text' placeholder='Enter your email' />
        <br />
        <input id='pass-input' className='log-input' type='password' placeholder='Enter your password' />
        <br />
        <div className='log-error-message' style={ this.parseError() }>

          Invalid sign in.
        </div>
        <button className='login-button' onClick={ this['startLogin'].bind(this) }>

          SIGN IN
        </button>
      </div>
    )
  }
}