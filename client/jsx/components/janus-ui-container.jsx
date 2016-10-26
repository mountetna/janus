import * as ReactRedux from 'react-redux';
import JanusUI from './janus-ui';

const mapStateToProps = (state, ownProps)=>{

  // state == redux store
  return {

    janusState: state['janusState']
  };
}

const mapDispatchToProps = (dispatch, ownProps)=>{

  return {};
}

const JanusUIContainer = ReactRedux.connect(

  mapStateToProps,
  mapDispatchToProps,
)(JanusUI);

export default JanusUIContainer;