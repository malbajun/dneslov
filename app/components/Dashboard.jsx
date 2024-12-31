import { Component } from 'react'
import { merge } from 'merge-anything'

import { calendaryMeta } from 'calendaryMeta'
import { memoryMeta } from 'memoryMeta'
import { nameMeta } from 'nameMeta'
import { memoMeta } from 'memoMeta'
import { orderMeta } from 'orderMeta'
import { subjectMeta } from 'subjectMeta'
import { scriptumMeta } from 'scriptumMeta'
import { readingMeta } from 'readingMeta'
import { roleMeta } from 'roleMeta'
import { userMeta } from 'userMeta'
import { homeMeta } from 'homeMeta'
import Home from 'Home'
import User from 'User'
import Login from 'Login'
import Records from 'Records'

const Metas = {
   'calendaries': calendaryMeta,
   'memories': memoryMeta,
   'names': nameMeta,
   'memoes': memoMeta,
   'scripta': scriptumMeta,
   'readings': readingMeta,
   'subjects': subjectMeta,
   'roles': roleMeta,
   'user': [userMeta, User],
   'home': [homeMeta, Home],
}

export default class Dashboard extends Component {
   state = merge({}, this.props, { meta: null, page: "user" })

   // system
   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         let parts = window.location.href.split("#"),
             [meta, renderer] = Dashboard.remetaFor(parts[1])

         if (parts[1]) {
            return {
               prevProps: props,
               user: props.user,
               meta: meta,
               renderer: renderer,
               page: parts[1]
            }
         } else {
            return {
               prevProps: props,
               user: props.user,
               meta: null,
               renderer: null,
               page: null
            }
         }
      }

      return null
   }

   static remetaFor(page) {
      let renderer, meta

      if (page && Metas[page].constructor.name == "Array") {
         renderer = Metas[page][1]
         meta = Metas[page][0]
      } else {
         renderer = Records
         meta = Metas[page]
      }

      return [meta, renderer]
   }

   onClick(page) {
      let [meta, renderer] = Dashboard.remetaFor(page)

      this.setState({ meta: meta, page: page, renderer: renderer, meta: meta })
   }

   componentDidCatch(error, errorInfo) {
      console.log(error, errorInfo)
   }

   onSigninUser(user) {
      this.setState({ user: user })
   }

   onSignoutUser() {
      this.setState({ user: null })
   }

   metas() {
      return Object.entries(Metas).map(([path, metaIn]) => {
         let meta = metaIn, renderer = null

         if (metaIn && metaIn.constructor.name == "Array") {
            renderer = metaIn[1]
            meta = metaIn[0]
         }

         return meta.title ? [path, meta, renderer] : null
      }).compact()
   }

   render() {
      console.log("[Dashboard] * props", this.props, "state", this.state)

      return (
         [<header>
            <nav className='terracota'>
               <div className="nav-wrapper admin">
                  <a className='brand-logo'
                     href='/'
                     alt="Днеслов">
                     <img
                        src="/dneslov-title.png" /></a>
                  <ul id="nav-mobile" className="right hide-on-med-and-down">
                     {this.state.user && this.metas().map(([path, meta, _renderer]) =>
                        <li>
                           <a
                              href={"#" + path}
                              onClick={this.onClick.bind(this, path)} >
                              {meta.title}</a></li>)}
                     <Login
                        onSigninUser={this.onSigninUser.bind(this)}
                        onSignoutUser={this.onSignoutUser.bind(this)}
                        onClick={this.onClick.bind(this, "home")}
                        user={this.state.user} /></ul></div></nav></header>,
         <main key='main'>
            <div className='container admin'>
               {this.state.page &&
                  <div className='row'>
                     <div className='col s12 m12 l12 xl12'>
                        <div id='page'>
                           {this.state.user &&
                              <this.state.renderer
                                 page={this.state.page}
                                 meta={this.state.meta}
                                 user={this.state.user}
                                 text_languages={this.state.text_languages}
                                 service_languages={this.state.service_languages} />}
                           </div></div></div>}</div></main>,
         <div className="progress">
            <div className="indeterminate"></div></div> ])}}
