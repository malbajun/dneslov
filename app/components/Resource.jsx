import { Component } from 'react'
import PropTypes from 'prop-types'
import { mixin, flow } from 'lodash-decorators'

import ErrorSpan from 'ErrorSpan'
import Validation from 'Validation'
import Subscribed from 'mixins/Subscribed'

import { valueToObject } from 'support'

@mixin(Subscribed)
@mixin(Validation)
export default class Resource extends Component {
   static defaultProps = {
      name: 'file-upload',
      value: "",
      title: null,
      wrapperClassName: null,
      placeholder: null,
      source: null,
      data: {},
      validations: {},
      i18n: {
         attach: "Прицепить файл",
      }
   }

   static propTypes = {
      name: PropTypes.string.isRequired,
      value: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
      wrapperClassName: PropTypes.string.isRequired,
      title: PropTypes.string.isRequired,
      source: PropTypes.string,
      placeholder: PropTypes.string.isRequired,
      data: PropTypes.object,
      validations: PropTypes.object.isRequired,
      validation_context: PropTypes.object.isRequired,
   }

   // system
   constructor(props) {
      super(props)
      console.debug("[constructor] <<< ", props.value, props.default)

      this.onClick = this.onClick.bind(this)
      this.onChange = this.onChange.bind(this)
   }

   @flow('componentDidMountBefore')
   componentDidMount() {
      if (this.props.data && this.props.data['length']) {
         this.counter = CharacterCounter.init(this.$input)
      }

      this.componentDidRender()
   }

   @flow('componentWillUnmountBefore')
   componentWillUnmount() {
      if (this.counter) {
         this.counter.destroy()
         this.counter = null
      }
   }

   componentDidUpdate() {
      this.componentDidRender()
   }

   componentDidRender() {
      console.debug("[componentDidRender] <<<")
   }

   shouldComponentUpdate(nextProps, nextState) {
      return this.getValue() !== nextProps.value
   }

   // events
   onClick(e) {
      console.log("[onClick] <<<", e)

      e.preventDefault()
      this.$input.click()
   }

   onChange(e) {
      console.log("[onChange] <<<", e)
      let file = e.target.files[0],
          reader = new FileReader(), url, object, ce

      reader.onloadend = function (e) {
         object = valueToObject(this.props.name, reader.result)
         ce = new CustomEvent('dneslov-update-path', { detail: { value: object, path: this.props.name }})

         document.dispatchEvent(ce)
      }.bind(this)

      url = reader.readAsDataURL(file)
      this.name = file.name

      console.log(e.target.value, url, object)
   }

   className() {
      return [ "resource input-field",
               this.props.wrapperClassName,
               this.getErrorText(this.getValue()) && 'invalid' ].
         filter((x) => { return x }).join(" ")
   }

   getValue() {
      if (this.props.value) {
         return this.props.value
      } else if (this.props.source) {
         return this.props.validation_context[this.props.source]
      }
   }

   actionText() {
      if (this.getValue()) {
         return "file_upload"
      } else {
         return "attach_file"
      }
   }

   buttonText() {
      if (this.getValue()) {
         return this.name
      } else {
         return this.props.i18n.attach
      }
   }

   render() {
      console.log("[render] * props:", this.props)

      return (
         <div
            className={this.className()}>
            {this.getValue() && <img
               alt={this.name}
               src={this.getValue()}
               onClick={this.onClick}
               className={this.props.wrapperClassName} />}
            {!this.getValue() && <button
               type='button'
               className='btn btn-primary'
               onClick={this.onClick} >
               <i className="material-icons left">{this.actionText()}</i>
               <span>
                 {this.buttonText()}</span></button>}
            <div
               className="file-input">
               <input
                  ref={e => this.$input = e}
                  type="file"
                  placeholder={this.props.i18n.upload}
                  onChange={this.onChange} /></div>
            <label
               className='active uploader'
               htmlFor={this.props.name}>
               {this.props.title}
               <ErrorSpan
                  error={this.getErrorText(this.getValue())} /></label></div>
      )
   }
}
