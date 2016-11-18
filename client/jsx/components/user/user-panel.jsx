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

          { 'User Email : '} { this['props']['appState']['userInfo']['userEmail'] }
        </div>
        <br />
        <div>

          { 'First Name : '} { this['props']['appState']['userInfo']['firstName'] }
        </div>
        <br />
        <div>

          { 'Last Name  : '} { this['props']['appState']['userInfo']['lastName'] }
        </div>
        <br />
        <div>

          { 'Auth Token : '} { this['props']['appState']['userInfo']['authToken'] }
        </div>
      </div>
    );
  }
}