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

   // custom
   render() {
      console.log("[render] * this.props:", this.props)

      return [
         <div className="row">
            <Form
               remoteName={this.props.meta.remoteName}
               remoteNames={this.props.meta.remoteNames}
               meta={this.props.meta.form}
               unoName={this.props.meta.unoName}
               data={this.props.user} /></div>,
         <div className="row">
            <SubmitButton
               title={this.props.meta.create} /></div>]
   }
}
