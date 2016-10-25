import * as React from 'react'

export default class LoginPanel extends React.Component{


  constructor(){

    super();
  }

  startLogin(){

    var userEmail = document.getElementById('email-input').value;
    var userPass = document.getElementById('pass-input').value;
    this['props']['callbacks'].startLogin(userEmail, userPass);
  }

  render(){

    return (

      <div id='login-group'>

        <input id='email-input' className='log-input' type='text' placeholder='Enter your email' value='jason.cater@ucsf.edu' />
        <br />
        <input id='pass-input' className='log-input' type='password' placeholder='Enter your password' />
        <br />
        <button className='login-button' onClick={ this['startLogin'].bind(this) }>

          LOGIN
        </button>
      </div>
    )
  }
}