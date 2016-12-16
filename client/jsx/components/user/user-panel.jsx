import * as React from 'react';

export default class UserPanel extends React.Component{

  constructor(){

    super();
  }

  render(){

    return (

      <div id='user-group'>

        <div>

          { 'User Email : '} { this['props']['userInfo']['userEmail'] }
        </div>
        <br />
        <div>

          { 'First Name : '} { this['props']['userInfo']['firstName'] }
        </div>
        <br />
        <div>

          { 'Last Name  : '} { this['props']['userInfo']['lastName'] }
        </div>
        <br />
        <div>

          { 'Auth Token : '} { this['props']['userInfo']['authToken'] }
        </div>
      </div>
    );
  }
}