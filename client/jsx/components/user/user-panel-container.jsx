import * as ReactRedux from 'react-redux';
import UserPanel from './user-panel';

const mapStateToProps = (state, ownProps)=>{

  // state == redux store
  return {

    appState: state['appState']
  };
}

const mapDispatchToProps = (dispatch, ownProps)=>{

  return {};
}

const UserPanelContainer = ReactRedux.connect(

  mapStateToProps,
  mapDispatchToProps,
)(UserPanel);

export default UserPanelContainer;