import * as React from 'react'

export default class TitleBar extends React.Component{

  constructor(){

    super();
  }

  render(){
    
    return (

      <div id='title-menu'>

        <button className='title-menu-btn'>
            
          { 'Janus' }
          <br />
          <span>

            AUTHSERVER
          </span>
        </button>
        <img id='ucsf-logo' src='/img/ucsf_logo_dark.png' alt='' />
      </div>
    );
  }
}