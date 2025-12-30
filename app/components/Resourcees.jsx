import { Component } from 'react'
import { mixin } from 'lodash-decorators'
import PropTypes from 'prop-types'

import Spans from 'Spans'
import MetaTags from 'react-meta-tags'
import ReactScrollPagination from '@majioa/react-scroll-pagination'

export default class Resourcees extends Component {
   static defaultProps = {
      list: [],
      total: null,
      url: "/api/v0/resources",

      grid: true,
      active: null,
      name: 'resources',
      i18n: {
         title: "Чинопоследования",
      },
      scheme: {
         header: [
            {span: ["title", "abbreviation"]}
         ],
      },

      onPushSubmit: null,
   }

   static propTypes = {
      list: PropTypes.array.isRequired,
      total: PropTypes.number.isRequired,

      active: PropTypes.string,
      wrapperYearDateClass: PropTypes.string,
      selectedCalendaries: PropTypes.array,
      calendarStyle: PropTypes.string,
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         return {
            prevProps: props,
            list: props.list,
            count: props.list.length,
            tagKeywords: Resourcees.getKeywords(props),
            tagDescription: Resourcees.getDescription(props),
            tagTitle: Resourcees.getTitle(props),
         }
      }

      return null
   }

   static getKeywords(props) {
      let re = RegExp("[\\s,]+", "i"),
          array = [
         props.list.map((object) => object.title?.split(re))
      ].flat().compact().uniq()

      return array.join(", ").slice(0, 255)
   }

   static getTitle(props) {
      let array = [
         props.list.map((object) => object.title)
      ].flat().uniq()

      return array.join(" ").slice(0, 255)
   }

   static getDescription(props) {
      let array = [
         props.list.map((object) => object.description),
         props.list.map((object) => object.title)
      ].flat().compact().uniq()

      return array.join(" ").slice(0, 255)
   }

   state = {}

   // system
   constructor(props) {
      super(props)

      this.onLoadRequest = this.onLoadRequest.bind(this)
   }

   onLoadRequest(id) {
      let url = '/' + this.props.name + '/' + id + '.json'

      this.props.onPushSubmit(null, url)
   }

   render() {
      console.log("[render] *", { 'this.props': this.props, 'this.state': this.state })

      return [
         <MetaTags>
            <meta
               id="meta-title"
               name="title"
               content={this.state.tagTitle} />
            <meta
               id="meta-keywords"
               name="keywords"
               content={this.state.tagKeywords} />
            <meta
               id="meta-description"
               name="description"
               content={this.state.tagTitle} /></MetaTags>,
         <h4>
            <span>{this.props.i18n.title}</span></h4>,
         <div className={'row ' + this.props.name}>
            <Spans
               list={this.state.list}
               total={this.props.total}
               url={this.props.url}
               thumb_url={this.props.thumb_url}
               name={this.props.name}
               scheme={this.props.scheme}
               hideIfBlank={true}
               manualFetch={true}
               onLoadRequest={this.onLoadRequest} /></div>]
   }
}
