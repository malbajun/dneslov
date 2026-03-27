import { Component } from 'react'
import PropTypes from 'prop-types'
import { mixin, flow } from 'lodash-decorators'
import axios from 'axios'
import { merge } from 'merge-anything'

import Validation from 'Validation'
import Subscribed from 'mixins/Subscribed'
import ValueToObject from 'mixins/ValueToObject'
import RepathTo from 'mixins/RepathTo'
import DynaText from 'DynaText'

@mixin(Subscribed)
@mixin(Validation)
@mixin(ValueToObject)
@mixin(RepathTo)
export default class DynamicField extends Component {
   static defaultProps = {
      id: null,
      pathname: null,
      key_name: null,
      value_name: null,
      name: 'text_id',
      humanized_name: 'text',
      value: "", // previously stored value
      humanized_value: undefined, // previously stored value name
      default: "", // default value
      humanized_default: undefined, // default value name
      begin: null,
      end: null,
      queryKey: 'q',
      selectable: false,
      wrapperClassName: null,
      title: null,
      placeholder: null,
      subscribeTo: null,
      validations: {},
   }

   static propTypes = {
      pathname: PropTypes.string.isRequired,
      key_name: PropTypes.string.isRequired,
      value_name: PropTypes.string.isRequired,
      humanized_name: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      begin: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
      end: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
      selectable: PropTypes.bool.isRequired,
      wrapperClassName: PropTypes.string.isRequired,
      title: PropTypes.string.isRequired,
      placeholder: PropTypes.string.isRequired,
      subscribeTo: PropTypes.oneOfType([PropTypes.string, PropTypes.array]),
      validations: PropTypes.object.isRequired,
   }

   // base on data, and value
   static generatedMatchList(dataIn, valueIn, permutationLimitCount = 5) {
      console.debug("[generatedMatchList] <<< dataIn:", dataIn, "valueIn:", valueIn, "permutationLimitCount:", permutationLimitCount)

      let value = valueIn || "", rex, re, matchList, m, sz, tx, tokens

      if (permutationLimitCount) {
         tokens = value.split(/\s+/).compact().slice(0, 5)
         rex = "(?:" + tokens.permutation().map(tokens => {
            return "(?:^|\\s|\\(|:)" + tokens.join(".*\\s")
         }).join("|") + ")"
         re = new RegExp(rex, "i")
      } else {
         re = new RegExp(value.escapeRegExp())
      }

      matchList = dataIn.list.reduce((a, x) => {
         if (x.value && (m = x.value.match(re))) {
            return a.concat([{text: x.value, match: m, value: x.key}])
         } else {
            return a
         }
      }, []).sort((a, b) => {
         sz = a.match.size < b.match.size ? -1 : a.match.size > b.match.size ? 1 : 0
         tx = a.text.localeCompare(b.text)

         return sz == 0 ? tx : sz
      })

      console.debug("[generatedMatchList] >>>", matchList)
      return matchList
   }

//   data = {list: [{value: this.props.humanized_value, key: this.props.value}], total: 1}
//   state = {
//      start: this.props.begin,
 //     end: this.props.end,
//      matchList: DynamicField.generatedMatchList(this.data, this.props.humanized_value, false),
//   }

   @flow('componentDidMountBefore')
   componentDidMount() {
      //console.debug("[componentDidMount1]1 ** ", this, this.props, this.data, this.props.value)
      console.debug("[componentDidMount1]1 ** ", this.props.name, this, this.props.value)

//      if (this.isRangeEnabled()) {
//         let range = new Range

///         console.log("wwwwww", this.$span, this.props.begin, this.props.end)
//         range.setStart(this.$span, this.props.begin)
         //range.setEnd(this.$span, this.props.end)

//         if (this.props.begin < this.props.end) {
 //           this.setState({range: range})
//         }
//      }
   }

   @flow('componentWillUnmountBefore')
   componentWillUnmount() {
      console.debug("[componentWillUnmount] <<<")
   }

   componentDidUpdate() {
      console.debug("[componentDidUpdate] <<<")
   }

   onChipAct() {
      let object = this.valueToObject(this.props.name, null),
          ce = new CustomEvent('dneslov-update-path', { detail: { value: object, path: this.props.name }})

      console.debug("[onSubscribedChanged:onChipAct] <<< ", object)
      console.log("[onChipAct] * unfix with", object)
      document.dispatchEvent(ce)
   }

   //actions
   updateTo(humanizedValue, value) {
      let valueDetail = this.valueToObject(this.props.name, value),
          detail = merge({}, this.valueToObject(this.props.humanized_name, humanizedValue), valueDetail), ce

      console.debug("[updateTo] ** value:", value, "detail:", detail, "valueDetail:", valueDetail, "huName: ", this.props.humanized_name)
      ce = new CustomEvent('dneslov-update-path', merge({}, { detail: { value: detail, path: this.props.name }}))
      document.dispatchEvent(ce)
   }

   onApplyRange(beginName, posStart, endName, posEnd) {
      let valueDetail = merge({}, this.valueToObject(beginName, posStart), this.valueToObject(endName, posEnd)),
          ce = new CustomEvent('dneslov-update-path', merge({}, { detail: { value: valueDetail, path: this.props.name }}))


      console.debug("[onApplyRange] wwww ** posOffset, ** posStart:", posStart, "posEnd:", posEnd, "ce", ce)

      document.dispatchEvent(ce)
   }

   // conditional
   isMultiline() {
      return this.props.display_scheme == "12-12-12-12"
   }

   // render
   render() {
      console.log("[render] * props:", this.props, "state: ", this.state)

      return (
         <div>
            <DynaText
               pathname={this.props.pathname}
               key_name={this.props.key_name}
               value_name={this.props.value_name}
               name={this.props.name}
               humanized_name={this.props.humanized_name}
               value={this.props.value}
               humanized_value={this.props.humanized_value}
               default={this.props.default}
               humanized_default={this.props.humanized_default}
               begin={this.props.begin}
               end={this.props.end}
               queryKey={this.props.queryKey}
               selectable={this.props.selectable}
               title={this.props.title}
               placeholder={this.props.placeholder}
               wrapperClassName={this.props.wrapperClassName}
               onUpdateTo={this.props.updateTo}
               onChipAct={this.props.onChipAct}
               onApplyRange={this.props.onApplyRange}
            /></div>)
   }
}
