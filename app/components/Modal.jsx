import { Component } from 'react'
import PropTypes from 'prop-types'

import SubmitButton from 'SubmitButton'
import Form from 'Form'

export default class Modal extends Component {
   static defaultProps = {
      remoteName: null,
      remoteNames: null,
      remoteCreate: null,
      meta: null,
      data: null,

      i18n: {
         close: {
            yes: "Да",
            title: "Закрываем без сохранения?",
            tab: "Вы хотите закрыть вкладку. Точно закрыть?"
         }
      }
   }

   static propTypes = {
      remoteName: PropTypes.string.isRequired,
      remoteNames: PropTypes.string.isRequired,
      remoteCreate: PropTypes.string,
      meta: PropTypes.object.isRequired,
      data: PropTypes.object.isRequired,
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         return {
            prevProps: props,
            data: props.data,
         }
      }

      return null
   }

   //system
   state = {}

   componentDidMount() {
      this.componentDidRender()
   }

   componentWillUnmount() {
      this.modal?.destroy()
   }

    componentDidUpdate() {
      this.componentDidRender()
   }

   // custom
   componentDidRender() {
      if (this.state.data) {
         let elems = this.$modal.parentElement.querySelectorAll('.modal'),
             modals = M.Modal.init(elems, {
            onCloseEnd: this.onModalClosed.bind(this)
         })

         console.debug("[componentDidRender] **", elems, modals)
         this.modal = modals[0]
         this.modal.open()

         window.onbeforeunload = this.confirmExit.bind(this);
      }
   }


   confirmExit() {
      return this.props.i18n.close.tab
   }

   onModalClosed() {
      let ce = new CustomEvent('dneslov-modal-close', {})

      document.dispatchEvent(ce)
   }

   onCloseRequest() {
      let toast = {
         displayLength: 10000,
         classes: 'rounded',
         html: this.$toast.innerHTML,
      }

      this.toast = M.toast(toast)

      document.querySelector('.toast.rounded > .toast-action')
              .addEventListener('click', this.onClose.bind(this), { passive: true })
   }

   onClose() {
      let toast = document.querySelector('.toast-wrapper.form').parentElement

      this.toast.dismiss()
      this.modal?.close()
   }

   renderBlank() {
      this.modal?.close()
      this.modal?.destroy()

      return null
   }

   renderModal() {
      return (
         <div className='enrighten'>
            <div
               className={'toast-wrapper form'}
               key='toast'
               ref={e => this.$toast = e} >
               <span>{this.props.i18n.close.title}</span>
               <button
                  className="btn-flat toast-action"
                  onClick={this.onClose.bind(this)}>
                  {this.props.i18n.close.yes}</button></div>
            <div
               key={this.props.remoteName + '-form-modal'}
               className='form-modal modal modal-fixed-footer z-depth-2'
               ref={e => this.$modal = e}
               id={this.props.remoteName + '-form-modal'}>
               <div className='modal-content'>
                  <Form
                     remoteName={this.props.meta.remoteName}
                     remoteNames={this.props.meta.remoteNames}
                     remoteCreate={this.props.meta.remoteCreate}
                     meta={this.props.meta.form}
                     data={this.state.data} /></div>
               <div className="modal-footer">
                  <div className="row">
                     <div className="col xl12 l12 m12 s12">
                        <div className="row">
                              <button
                                 key='close-button'
                                 type='button'
                                 className='btn close'
                                 onClick={this.onCloseRequest.bind(this)} >
                                 {this.props.meta.close}</button>
                              <SubmitButton
                                 title={this.state.data.id &&
                                        this.props.meta.update ||
                                        this.props.meta.create } /></div></div></div></div></div></div>)
   }

   render() {
      console.log("[render] * props:", this.props, "state:", this.state)

      if (this.state.data) {
         return this.renderModal()
      } else {
         return this.renderBlank()
      }
   }
}
