import { Component } from 'react'
import PropTypes from 'prop-types'

import SubmitButton from 'SubmitButton'
import Form from 'Form'

export default class User extends Component {
   static defaultProps = {
      remoteName: null,
      remoteNames: null,
      meta: null,
      data: {},
      user: null,
   }

   static propTypes = {
      remoteName: PropTypes.string.isRequired,
      remoteNames: PropTypes.string.isRequired,
      meta: PropTypes.object.isRequired,
      data: PropTypes.object.isRequired,
      user: PropTypes.object,
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         return {
            prevProps: props,
            data: props.data,
            user: props.user
         }
      }

      return null
   }

   // system
   state = {}

   constructor(props) {
      super(props)

      //this.onRecordUpdate = this.onRecordUpdate.bind(this)
      //this.onModalClose = this.onModalClose.bind(this)
   }

   componentDidMount() {
      //this.submit()
      //document.addEventListener('dneslov-record-stored', this.onRecordUpdate, { passive: true })
      //document.addEventListener('dneslov-modal-close', this.onModalClose, { passive: true })
   }

   componentWillUnmount() {
      console.log("[componentWillUnmount] <<<")
      //document.removeEventListener('dneslov-record-stored', this.onRecordUpdate)
      //document.removeEventListener('dneslov-modal-close', this.onModalClose)
   }

   componentDidUpdate(nextProps) {
      //if (this.props != nextProps) {
      //   this.submit()
      //}
   }

   shouldComponentUpdate(nextProps, nextState) {
      console.debug("[shouldComponentUpdate] ** nextState:", nextState, "this.state:", this.state)
      return true
      //return JSON.stringify(nextState.query) !== JSON.stringify(this.state.query) ||
      //       nextState.current != this.state.current ||
      //       nextState.page != this.state.page
   }

   // custom
   render() {
      console.log("[render] * this.props:", this.props, "this.state:", this.state)

      return [
         <div className="row">
               <Form
                  remoteName={this.props.meta.remoteName}
                  remoteNames={this.props.meta.remoteNames}
                  meta={this.props.meta.form}
                  data={this.state.data} /></div>,

         <div className="row">
                              <SubmitButton
                                 title={this.props.meta.create} /></div>]
   }
}
