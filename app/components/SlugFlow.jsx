import { Component } from 'react'
import PropTypes from 'prop-types'
import { merge } from 'merge-anything'
import * as uuid from 'uuid/v1'
import { mixin, flow } from 'lodash-decorators'

import Validation from 'Validation'
import Subscribed from 'mixins/Subscribed'
import { renderElement } from 'render'
import ErrorSpan from 'ErrorSpan'
import { propsAsArray, valueToObject } from 'support'
import DynaText from 'DynaText'

@mixin(Subscribed)
@mixin(Validation)
export default class SlugFlow extends Component {

   static defaultProps = {
      pathname: null,
      name: null,
      value: [],
      title: null,
      meta: {},
      placeholder: null,
      wrapperClassName: null,
   }

   static propTypes = {
      pathname: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      value: PropTypes.array.isRequired,
      title: PropTypes.string.isRequired,
      meta: PropTypes.object.isRequired,
      validations: PropTypes.object,
      validation_context: PropTypes.object,
      wrapperClassName: PropTypes.string.isRequired,
   }

   static getDerivedStateFromProps(props, state) {
      if (!state.prevProps || props.value !== state.prevProps.value) {
         return {
            prevProps: props,
            value: propsAsArray(props)
         }
      }

      return null
   }

   // system
   state = { current: null }

   shouldComponentUpdate(nextProps, nextState) {
      console.debug("[shouldComponentUpdate] <<< ", nextProps,nextState.value,this.state.value)
      return this.state.value !== nextState.value
   }

   // system
   constructor(props) {
      super(props)
      console.debug("[componentDidMount:constructor] <<< ", props.value, props.default)
      let value, data

      this.onSelectFromList = this.onSelectFromList.bind(this)
      this.onChange = this.onChange.bind(this)
      this.onAddItem = this.onAddItem.bind(this)
      this.onUpdateTo = this.onUpdateTo.bind(this)
   }

   @flow('componentDidMountBefore')
   componentDidMount() {}

   @flow('componentWillUnmountBefore')
   componentWillUnmount() {}

   // events
   onAddItem() {
      console.debug("[onAddItem] <<<")
      this.setState({value: this.state.value.concat([""])})
   }

   // service
   onUpdateTo(valueIn, humanizedValue, name) {
      console.debug("[onUpdateTo] <<<", name, humanizedValue, valueIn)

      const regEx = /\[(\d+)\]/
      let newValue = this.state.value.with(name.match(regEx)[1], valueIn),
          object = valueToObject(this.props.name, newValue),
          e = new CustomEvent('dneslov-update-path', { detail: { value: object, path: this.props.name }})

      this.setState({value: newValue})

      document.dispatchEvent(e)
   }

   className() {
      return [ this.props.wrapperClassName,
               this.getErrorText(this.state.value) && 'invalid' ].
         filter((x) => { return x }).join(" ")
   }

   ///////////////////////////////////////////////////////
   //events
   onChange(e) {
      let humanized_value = e.target.value

      console.log("[onChange] * update to", humanized_value)
      this.updateTo(humanized_value, false)

      console.debug("[onChange] ** analyzing:", this.triggered,
         humanized_value, this.state.data, this.state.data && this.state.data.total,
         this.state.data && Object.keys(this.state.data.list).length)

      if (!this.triggered || humanized_value &&
          (!humanized_value.includes(this.triggered) &&
           !this.triggered.includes(humanized_value) ||
           this.state.data && (this.state.data.total > Object.keys(this.state.data.list).length &&
            humanized_value.includes(this.triggered) ||
            this.triggered.includes(humanized_value)))) {
         this.getDataFor(humanized_value)
      }
   }

   onSelectFromList(humanized_value, _value) {
      console.debug("[onSelectFromList] <<<:", humanized_value, _value)

      this.updateTo(humanized_value)
   }

   render() {
      console.log("[render] > state:", this.state, "from props:", this.props)

      return (
         <div className={this.className()}>
            <h5>{this.props.title}</h5>
            <div className='list'>
               {this.state.value.map((text, index) => {
                  return <DynaText
                     key={this.props.name + '-' + index}
                     wrapperClassName='slug-flow col s1 m1 l1 xl1'
                     pathname={this.props.pathname}
                     name={this.props.name + "[" + index + "]"}
                     placeholder={this.props.placeholder}
                     value={text}
                     onUpdateTo={this.onUpdateTo} />}
                  )}</div>
            <a
               className="btn btn-floating add-to-list"
               onClick={this.onAddItem} >
               <i
                  className="material-icons small"
                  onClick={this.onAddItem} >add</i></a>
            <ErrorSpan
               error={this.getErrorText(this.state.value)} /></div>
      )
   }
}
