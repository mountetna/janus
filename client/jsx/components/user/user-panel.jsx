import * as React from 'react';

export default class UserPanel extends React.Component{

  constructor(){

    super();
  }

  logOut(){

    this['props'].logOut();
  }

  render(){

    return (

      <div id='user-group'>

        <div>

          { 'User Email : '} { this['props']['janusState']['userInfo']['userEmail'] }
        </div>
        <br />
        <div>

          { 'First Name : '} { this['props']['janusState']['userInfo']['firstName'] }
        </div>
        <br />
        <div>

          { 'Last Name  : '} { this['props']['janusState']['userInfo']['lastName'] }
        </div>
        <br />
        <div>

          { 'Auth Token : '} { this['props']['janusState']['userInfo']['authToken'] }
        </div>
        <br />

        <button className='login-button' onClick={ this['logOut'].bind(this) }>

          SIGN OUT
        </button>
      </div>
    );
  }
}