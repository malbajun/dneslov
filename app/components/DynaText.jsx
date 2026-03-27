import { Component } from 'react'
import PropTypes from 'prop-types'
import { mixin } from 'lodash-decorators'
import axios from 'axios'
import { merge } from 'merge-anything'

import Validation from 'Validation'
import ErrorSpan from 'ErrorSpan'
import PopupList from 'PopupList'

@mixin(Validation)
export default class DynaText extends Component {
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
      onUpdateTo: null,
      onChipAct: null,
      onApplyRange: null,
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

   //data = {list: [], total: 0}
   state = {
      start: this.props.begin,
      end: this.props.end,
      matchList: [],
      data: {list: [], total: 0, overtotal: 0},
      value: null,
      humanizedValue: "",
      triggeredText: ""
   }

   // system
   constructor(props) {
      super(props)
      console.debug("[DynaText:constructor] <<< ", props.value, props.default)
      let value, data

      if (props.value) {
         if (props.value.constructor.name == "Object") {
            value = props.value.value
            data = { list: [{ value: value, key: props.value.key }], total: 1 }
            this.state.value = props.value.key
            this.state.humanizedValue = value
         } else {
            value = props.humanized_value
            data = { list: [{ value: props.humanized_value, key: props.value }], total: 1 }
            this.state.value = props.value
            this.state.humanizedValue = props.humanized_value
         }
      } else if (props.default) {
         value = props.humanized_default
         data = { list: [{ value: props.humanized_default, key: props.default }], total: 1 }
         this.state.value = props.default
         this.state.humanizedValue = props.humanized_default
      }

      if (data) {
         this.state.data = data
         this.state.matchList = DynaText.generatedMatchList(data, value, false)
      }

      this.onSelectFromList = this.onSelectFromList.bind(this)
      this.onKeyDown = this.onKeyDown.bind(this)
      this.onSelectionChange = this.onSelectionChange.bind(this)
      this.onSelectStart = this.onSelectStart.bind(this)
      this.onChange = this.onChange.bind(this)
      this.onChipAct = this.onChipAct.bind(this)
   }

   componentDidMount() {
      console.debug("[componentDidMount] ** ", this.props.name, this, this.props.value)

      document.addEventListener('keydown', this.onKeyDown)
      document.addEventListener('selectionchange', this.onSelectionChange, { passive: true })
      this.$span.addEventListener('selectstart', this.onSelectStart, { passive: true })
   }

   componentWillUnmount() {
      console.debug("[componentWillUnmount] <<<")
      this.$span.removeEventListener('selectstart', this.onSelectStart)
      document.removeEventListener('selectionchange', this.onSelectionChange)
      document.removeEventListener('keypress', this.onKeyDown)
   }

   shouldComponentUpdate(nextProps, nextState) {
      return nextState.pendingRange || nextState.selectApplied ||
             nextState.matchList != this.state.matchList ||
             this.state.value !== nextProps.value ||
             this.state.humanizedValue !== nextProps.humanized_value
   }

   //events
   onChange(e) {
      let humanizedValue = e.target.value

      console.log("[onChange] * update to", humanizedValue)
      this.updateTo(humanizedValue, false)

      console.debug("[onChange] ** analyzing:", this.triggered,
         humanizedValue, this.state.triggeredText, this.state.data.overtotal, this.state.data.total)

       if (!this.state.triggeredText ||
           humanizedValue != this.state.triggeredText &&
          (!humanizedValue.includes(this.state.triggeredText) &&
           !this.state.triggeredText.includes(humanizedValue) ||
           this.state.data.overtotal > this.state.data.total &&
          (humanizedValue.includes(this.state.triggeredText) ||
           this.state.triggeredText.includes(humanizedValue)))) {
         this.getDataFor(humanizedValue)
      }
   }

   onSelectFromList(humanized_value, _value) {
      console.debug("[onSelectFromList] <<<:", humanized_value, _value)

      this.updateTo(humanized_value)
   }

   onKeyDown(e) {
      if (e.key === "Enter" && e.target == this.$dropdown) {
         console.log("[onKeyDown] * fix to", this.$dropdown.value)
         e.preventDefault()
         if (this.state.data.list[this.$dropdown.value]) {
            this.updateTo(this.$dropdown.value)
         }
      }
   }

   onChipAct() {
      if (this.props.onChipAct) {
         this.props.onChipAct(this.props.name)
      }

      if (this.props.onUpdateTo) {
         this.props.onUpdateTo(name, this.state.humanizedValue, this.props.name)
      }

      this.setState({value: ""})
   }

   onSelectStart() {
      if (this.isRangeEnabled()) {
         this.setState({selectStart: true, selectApplied: false})
      }
   }

   onSelectionChange() {
      if (this.isRangeEnabled() && this.state.selectStart) {
         let selection = document.getSelection(),
             range = selection.getRangeAt(0)

         if (range.collapsed) {
            this.setState({pendingRange: null})
         } else {
            this.setState({pendingRange: range})
         }
      }
   }

   //actions
   updateTo(humanizedValue, autofix = true) {
      console.log("[updateTo] <<< humanizedValue:", humanizedValue, "autofix:", autofix)
      let value, data, permutationLimitCount

      if (autofix || this.state.data.total == 1) {
         value = this.state.data.list.find((r) => {
            return humanizedValue == r.value
         })?.key
      }

      if (value) {
         data = {list: [{value: humanizedValue, key: value}], total: 1, overtotal: 1}
         permutationLimitCount = false
      } else {
         data = this.state.data
         permutationLimitCount = 5
      }

      console.log("[updateTo] ****** data:", data.total)
      if (data.total > 0) {
         // data is matched so popup
         this.setState({
            matchList: DynaText.generatedMatchList(data, humanizedValue, permutationLimitCount),
            value: value,
            humanizedValue: humanizedValue
         })
      } else {
         // just update text on widget
         this.setState({value: value, humanizedValue: humanizedValue})
      }

      if (this.props.onUpdateTo && value) {
         this.props.onUpdateTo(value, humanizedValue, this.props.name)
      }
   }

   getContext(contextIn) {
      let ctx = contextIn || this.props.context_value || {}

      return Object.entries(ctx).reduce((res, [name, valueIn]) => {
         if (typeof(valueIn) == "function") {
            let value = valueIn()

            if (value) {
               res[name] = value
            }
         } else {
            res[name] = valueIn
         }

         return res
      }, {})
   }

   getDataFor(text) {
      console.debug("[getDataFor] <<<", text)
      let data = merge(this.getContext(), { [this.props.queryKey]: text })

      if (this.props.value_context) {
         Object.entries(this.getContext(this.props.value_context)).forEach(([key, value]) => {
            data["by_" + key] = value
         })
      }

      this.triggered = text

      var request = {
         data: data,
         url: '/' + this.props.pathname + '.json',
      }

      console.log("[getDataFor] * load send", data, 'to /' + this.props.pathname + '.json')
      axios.get(request.url, { params: request.data })
         .then(this.onLoadSuccess.bind(this))
         .catch(this.onLoadFailure.bind(this))
   }

   onLoadFailure() {
      console.debug("[onLoadFailure] <<<")
      this.triggered = undefined
   }

   onLoadSuccess(response) {
      let dynamic_data
      console.debug("[onLoadSuccess] <<<")

      if (response.data.list) {
         dynamic_data = response.data
      } else {
         let range = response.headers["content-range"]
         const { b, e, total } = /records (?<b>\d+)-(?<e>\d+)\/(?<total>\d+)/.exec(range,).groups;

         dynamic_data = {
            list: response.data || [],
            total: response.data.total || 0,
            overtotal: parseInt(total || response.data.total || 0)
         }
      }
      console.log("[onLoadSuccess] * dynamic data:", dynamic_data, "for: ",  this.triggered, "with response:", response)

      this.setState({
         matchList: DynaText.generatedMatchList(dynamic_data, this.triggered),
         data: dynamic_data,
         triggeredText: this.triggered
      })
      this.triggered = undefined
   }

   getElementIndex(el) {
      return Array.prototype.indexOf.call(el.parentNode.children, el)
   }

   onApplyRange() {
      let r = this.state.pendingRange,
          beginName = this.repathTo(this.props.name, "begin"),
          endName = this.repathTo(this.props.name, "end"),
          posEnd = r.endOffset, posStart = r.startOffset, posOffset = 0,
          prev = r.startContainer.parentNode.previousElementSibling?.firstChild,
          next = r.startContainer

      while (prev) {
         posOffset += prev.length
         prev = prev.parentNode.previousElementSibling?.firstChild
      }
      posStart += posOffset

      while (next && next != r.endContainer) {
         posOffset += next.length
         next = next.parentNode.nextElementSibling?.firstChild
      }
      posEnd += posOffset

      if (this.props.onApplyRange) {
         this.props.onApplyRange(beginName, posStart, endName, posEnd)
      }

      this.setState({
         pendingRange: null,
         start: posStart,
         end: posEnd,
         selectStart: null,
         selectApplied: true
      })
   }

   className() {
      return [ "input-field",
               this.props.wrapperClassName,
               this.getErrorText(this.state.value) && 'invalid' ].
         filter((x) => { return x }).join(" ")
   }

   getApplierPositionCss() {
      let rect = this.state.pendingRange.getBoundingClientRect(),
          span = document.elementFromPoint(rect.x, rect.y).getBoundingClientRect(),
          top = rect.bottom - span.top + 16, left = rect.right - span.left + 16
      console.debug("[getApplierPositionCss] ** rect:", top, left)

      return {top: `${top}px`, left: `${left}px`, position: "absolute"}
   }

   // conditional
   isRangeEnabled() {
      return this.props.selectable
   }

   spanValue() {
      let value = this.state.humanizedValue

      if (this.isRangeEnabled() && Number.isInteger(this.state.start)) {
         let pre = value.slice(0, this.state.start),
             mid = value.slice(this.state.start, this.state.end),
             post = value.slice(this.state.end, -1)

         return [<span className="plain">{pre}</span>,
                 <span className="plain selected">{mid}</span>,
                 <span className="plain">{post}</span>]
      } else {
         return <span className="plain">{value}</span>
      }
   }

   // render
   render() {
      console.log("[render] * props:", this.props, "state: ", this.state)

      return (
         <div
            ref={e => this.$dropspan = e}>
            <div
               ref={e => this.$span = e}
               data-target={'dyna-' + this.props.name}
               className={this.className() + " dropdown-trigger"}>
               {this.state.value &&
                  <div
                     className="chip">
                     <span>
                        {this.spanValue()}</span>
                     <i
                        className='material-icons unfix'
                        onClick={this.onChipAct}>
                        close</i>
                  {this.isRangeEnabled() && this.state.pendingRange &&
                     <a
                        style={this.getApplierPositionCss()}
                        onClick={() => {this.onApplyRange()}}
                        className="popup btn-floating btn-small waves-effect waves-light terracota">
                        <i className="small material-icons">fingerprint</i></a>}
                  </div>}
               {!this.state.value &&
                  [<input
                     type='text'
                     className={"'dynamic " + (this.getErrorText(this.state.value) && 'invalid')}
                     key={'input-' + PopupList.elementIdFromName(this.props.name)}
                     id={'input-' + PopupList.elementIdFromName(this.props.name)}
                     name={this.props.name}
                     placeholder={this.props.placeholder}
                     value={this.state.humanizedValue || ''}
                     onChange={this.onChange} />,
                  <PopupList
                     name={this.props.name}
                     list={this.state.matchList}
                     onSelectItem={this.onSelectFromList} />]
               }
               <label
                  className='active'
                  htmlFor={this.props.name}>
                  {this.props.title}
                  <ErrorSpan
                     error={this.getErrorText(this.state.value)} /></label></div></div>)
   }
}
