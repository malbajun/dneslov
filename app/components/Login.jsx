import { Component } from 'react'
import { merge } from 'merge-anything'
import axios from 'axios'

import { DiscordLogin } from '@schybo-quizzing/react-oauth-discord'
import TelegramLoginButton, { TelegramUser } from 'telegram-login-button'
import ReactModalLogin from "react-modal-login"

export default class Login extends Component {
   static defaultProps = {
      enabled: false,
      refreshToken: null,
      sessionToken: null,
      user: null,
      login_url: '/api/v1/session.json', //POST
      signup_url: '/api/v1/users/create.json', //POST
      recover_url: '/api/v1/session.json', //PUT
      user_info_url: '/api/v1/user.json', //GET
      refresh_token_url: '/api/v1/session.json', //POST
      wechatRedirectUri: "http://localhost:4000/api/wechatlogin",
      wechatAppId: "",
      discordClientId: "",
      discordRedirectUri: "http://localhost:4000/api/discordlogin",
      onSignoutUser: null,
      onSigninUser: null,
      i18n: {
         login_error: "Невозможно войти",
         signup_error: "Невозможно зарегистрироваться",
         recover_error: "Невозможно восстановить пароль",
         login: "Вход",
         signup: "Регистрация",
         recover: "Восстановление пароля",
         recover_button: "Восстановление",
         user_email_placeholder: "Введите почтовый адрес",
         user_password_placeholder: "Введите пароль",
         user_password_confirmation_placeholder: "Повторите пароль",
      },
      uloginParams: {
         display: "panel",
         theme: "classic",
         fields: ["first_name", "last_name", "email", "nickname", "sex", "bdate", "photo", "photo_big"],
         providers: ["vkontakte", "odnoklassniki", "mailru", "livejournal"],
         mobilebuttons: "0",
         verify: "1",
         redirect_uri: "",
         lang: "ru",
      },
      form: {
         loginInputs: [
            {
               type: "email",
               name: "account[email]",
            },
            {
               type: "password",
               name: "account[password]",
            },
         ],
         registerInputs: [
            {
               type: "email",
               name: "account[email]",
            },
            {
               type: "password",
               name: "account[password]",
            },
            {
               type: "password",
               name: "account[password_confirmation]",
            },
         ],
         recoverPasswordInputs: [
            {
               type: "email",
               name: "account[email]",
            },
         ],
         loginBtn: {
            buttonClass: "login btn waves-effect waves-light",
         },
         registerBtn: {
            buttonClass: "signup btn waves-effect waves-light",
         },
         recoverPasswordBtn: {
            buttonClass: "recover-button btn waves-effect waves-light",
         },
         recoverPasswordAnchor: {
            buttonClass: "recover-anchor",
         },
      }
   }

   state = {
      showModal: false,
      loading: false,
      error: null,
      user: null,
      refreshToken: null,
      sessionToken: null,
   }

   // system
   static getDerivedStateFromProps(propsIn, stateIn) {
      console.debug("[getDerivedStateFromProps] <<<", { props: propsIn, state: stateIn })

      if (propsIn !== stateIn.prevProps) {
         let state = {
            user: propsIn.user,
            refreshToken: propsIn.user && stateIn.refreshToken || propsIn.refreshToken || propsIn.user?.refresh_token?.code,
            sessionToken: propsIn.user && stateIn.sessionToken || propsIn.sessionToken || propsIn.user?.session_token?.code,
         }

         console.debug("[getDerivedStateFromProps] <<<", { toNewState: state })
         return state
      }

      return null
   }

   // system
   constructor(props) {
      super(props)

      this.onAvatarClick = this.onAvatarClick.bind(this)
      this.loginDiscord = this.loginDiscord.bind(this)
      this.startLoading = this.startLoading.bind(this)
      this.finishLoading = this.finishLoading.bind(this)
      this.onLoginWechat = this.onLoginWechat.bind(this)
      this.onTelegramDataAuth = this.onTelegramDataAuth.bind(this)
      this.onSignoutClick = this.onSignoutClick.bind(this)
      this.afterTabsChange = this.afterTabsChange.bind(this)
      this.closeModal = this.closeModal.bind(this)
   }

   componentDidMount() {
      this.componentDidRender()
   }

   componentDidUpdate(prevProps, prevState) {
      this.componentDidRender()
   }

   componentDidRender() {
      axios.defaults.headers.common["Content-Type"] = 'application/json'

      if (this.state.sessionToken) {
         axios.defaults.headers.common["Authorization"] = "Session " + this.state.sessionToken
      }

      console.debug("[componentDidRender] ***", axios.defaults.headers.common)
   }

   componentDidCatch(error, errorInfo) {
      console.log(error, errorInfo)
   }

   // events
   onClick(meta, page) {
      this.setState({ meta: meta, page: page })
   }

//   onLoginSuccess(data) {
//      this.setState(data)
//   }

   onLoginFailure(e) {
      console.error("Sign-in error: " + e.error)
   }

   onAvatarClick(e) {
      this.avatarTap.open()
   }

   // props
   openModal() {
      this.setState({ showModal: true })
   }

   closeModal() {
     this.setState({ showModal: false, error: null })
   }

   afterTabsChange() {
      this.setState({ error: null })
   }

   startLoading() {
      this.setState({ loading: true });
   }

   finishLoading() {
      this.setState({ loading: false });
   }

   isAvatarTappen() {
      return !!this.$avatarSignIn.querySelector('.tap-target-wrapper.open')
   }

   async getUser() {
      try {
         let params = {}
         const response = await axios.get(this.props.user_info_url, params);
         console.log(response);
      } catch (error) {
         console.error(error);
      }
   }

   async refreshToken() {
      let headers = { 'Authorization': 'Refresh ' + this.state.refreahToken }

      try {
         const response = await axios.get(this.props.refresh_token_url, { headers: headers });
         console.log(response);
      } catch (error) {
         console.error(error);
      }
   }

   onLogin() {
      let serialized = {},
          email = document.querySelector('.RML-login-modal-form [name="account[email]"]'),
          password = document.querySelector('.RML-login-modal-form [name="account[password]"]')

      serialized["no"] = email.value
      serialized["type"] = "Account::Email"
      serialized["password"] = password.value

      axios.post(this.props.login_url, { account: serialized })
         .then(this.onLoginSuccess.bind(this))
         .catch(this.onAxiosFailure.bind(this))
   }

   onSignup() {
      let serialized = {},
          email = document.querySelector('.RML-login-modal-form [name="account[email]"]'),
          password = document.querySelector('.RML-login-modal-form [name="account[password]"]'),
          passwordc = document.querySelector('.RML-login-modal-form [name="account[password_confirmation]"]')

      serialized = {
         "user": {
            "password": password.value,
            "password_confirmation": passwordc.value,
            "accounts_attributes": [{
               "no": email.value,
               "type": "Account::Email"
            }]
         }
      }

      axios.post(this.props.signup_url, serialized)
         .then(this.onSignupSuccess.bind(this))
         .catch(this.onAxiosFailure.bind(this))
   }

   onRecover() {
      let serialized = {},
          email = document.querySelector('.RML-login-modal-form [name="account[email]"]')

      serialized["no"] = email.value
      serialized["type"] = "Account::Email"

      axios.put(this.props.recover_url, { account: serialized })
         .then(this.onRecoverSuccess.bind(this))
         .catch(this.onAxiosFailure.bind(this))
   }

   onAxiosFailure(error) {
      console.debug("[onAxiosFailure] <<<", error)
      let response, errorText = "."

      try {
         response = error.response
      } catch (_error) {}

      if (response) {
         errorText = ": [" + error.response.status.toString() + "] "

         if (error.response.data["error"]) {
            console.debug("[onAxiosFailure] **", error.response.data["error"])
            errorText = errorText + error.response.data["error"].join(", ")
         }
      }

      console.debug("[onAxiosFailure] ***", error)
      this.setState({ error: errorText})
   }

   onLoginSuccess(response) {
      console.debug("[onLoginSuccess] <<<", response)
      console.debug("[onLoginSuccess] **", response.data)
      this.props.onSigninUser(response.data)

      this.setState({showModal: false})
      //this.setState({showModal: false, error: null, user: response.data})
   }

   onSignupSuccess(response) {
      console.debug("[onSignupSuccess] <<<", response)
      this.setState({showModal: false, error: null, showModal: false, float: this.props.i18n.verify_email})
   }

   onRecoverSuccess(response) {
      console.debug("[onRecoverSuccess] <<<", response)
      this.setState({showModal: false, error: null})
   }

   info() {
      return [ this.state.info, this.state.location ].filter(e => { return e }).join("\n")
   }

   onSignoutClick() {
      axios.delete('/api/v1/session.json')
         .then(this.onSignoutSuccess.bind(this))
         .catch(this.onSignoutFailure.bind(this))
   }

   onSignoutSuccess(response) {
      this.setState({showModal: false})

      this.props.onSignoutUser()
   }

   onSignoutFailure(response) {
      this.setState({showModal: false})

      // signout anyway
      this.props.onSignoutUser()
   }

   onLoginWechat(res) {
   }

   onTelegramDataAuth(a) {
      //dataOnauth={(user: TelegramUser) => console.log(user)}
   }

   loginDiscord() {
      //const params = new Proxy(new URLSearchParams(window.location.search), {
      //  get: (searchParams, prop) => searchParams.get(prop),
      //});
      //let value = params.code;
   }

   networkButtons() {
      let args = merge({}, this.props.uloginParams, {redirect_uri: document.location.href + '/auth/ulogin'})

      return <div className="login-wrapper">
         <div
            id="uLogin"
            data-ulogin={"display=panel;theme=classic;fields=first_name,last_name,email,nickname,sex,bdate,photo,photo_big;providers=vkontakte,odnoklassniki,mailru,twitter,livejournal;redirect_uri=https%3A%2F%2Flocalhost%3A33333%2Fauth%2Fulogin%3F_csfr_token%3D" + this.csrf_token +";mobilebuttons=0;verify=1;lang=ru;"}
            className='sign-in'></div>
         <TelegramLoginButton
            botName="dneslovic"
            buttonSize="large"
            className="button telegram"
            cornerRadius="2"
            dataOnauth={this.onTelegramDataAuth}
         />
         <DiscordLogin
            discordClientId={this.props.discordClientId}
            redirectUri={this.props.discordRedirectUri}
            onClick={this.loginDiscord}
            debug={true}
            backgroundColor="transparent"
            size="large"
            newTab={false}
            buttonClasses={"button discord"}
         /></div>
   }

   getForm() {
      return merge({}, this.props.form, {
         onLogin: this.onLogin.bind(this),
         onRegister: this.onSignup.bind(this),
         onRecoverPassword: this.onRecover.bind(this),
         loginBtn: {
            label: this.props.i18n.login,
         },
         registerBtn: {
            label: this.props.i18n.signup,
         },
         recoverPasswordBtn: {
            label: this.props.i18n.recover_button,
         },
         recoverPasswordAnchor: {
            label: this.props.i18n.recover
         },
         bottomLoginContainer: this.networkButtons(),
         bottomRegisterContainer: this.networkButtons(),
         loginInputs: [
            {
               type: "email",
               name: "account[email]",
               placeholder: this.props.i18n.user_email_placeholder,
            },
            {
               type: "password",
               name: "account[password]",
               placeholder: this.props.i18n.user_password_placeholder,
            },
         ],
         registerInputs: [
            {
               type: "email",
               name: "account[email]",
               placeholder: this.props.i18n.user_email_placeholder,
            },
            {
               type: "password",
               name: "account[password]",
               placeholder: this.props.i18n.user_password_placeholder,
            },
            {
               type: "password",
               name: "account[password_confirmation]",
               placeholder: this.props.i18n.user_password_confirmation_placeholder,
            },
         ],
         recoverPasswordInputs: [
            {
               type: "email",
               name: "account[email]",
               placeholder: this.props.i18n.user_email_placeholder,
            },
         ],
      })
   }

   getLogin() {
      let login = this.state.user.accounts.find((x) => { return x.type == "Account::Uid" })

      return login?.no
   }

   getName() {
      return "";

      let names = this.state.user.settings.names || []

      names.find((x) => { return x.text && x.kind })

   }

   render() {
      console.log("[render] * ", { props: this.props, state: this.state})

      this.csrf_token = document.querySelector('meta[name=csrf-token]').getAttribute('content')

      return <ul id="nav-mobile" className="right">
         {this.state.user && [
            <li>
               <a
                  onClick={this.onSignoutClick}
                  href="#">
                  {"Выход"}</a></li>,
            <li>
               <div
                  ref={e => this.$avatarSignIn = e}
                  key='avatarSignIn'
                  className='moon circle btn-floating btn-large signed'>
                  {this.state.user.info?.avatar_url &&
                     <img
                        id='avatar'
                        className='circle z-depth-1 responsive-img'
                        onClick={this.onAvatarClick}
                        src={this.state.user.info?.avatar_url} />}
                  {!this.state.user.info?.avatar_url &&
                        <a
                           href={"/dashboard#home"}>
                        <i
                           className="material-icons">
                           perm_identity</i></a>}
                  <div
                     key='avatarTap'
                     ref={e => this.$avatarTap = e}
                     className='tap-target'
                     data-target='avatar'>
                     <div
                        className='tap-target-content'>
                        <h6>
                           {this.getLogin()}</h6>
                        <h5>
                           {this.getName()}</h5>
                        <p>
                           {this.info()}</p></div></div></div></li>,
         ]}
         {!this.state.user &&
            <li>
               <ReactModalLogin
                  visible={this.state.showModal}
                  onCloseModal={this.closeModal}
                  loading={this.state.loading}
                  error={this.state.error}
                  tabs={{
                     afterChange: this.afterTabsChange,
                     loginLabel: this.props.i18n.login,
                     registerLabel: this.props.i18n.signup,
                  }}
                  loginError={{
                     label: this.props.i18n.login_error + (this.state.error ? this.state.error : "")
                  }}
                  registerError={{
                     label: this.props.i18n.signup_error + (this.state.error ? this.state.error : "")
                  }}
                  recoverPasswordError={{
                     label: this.props.i18n.recover_error + (this.state.error ? this.state.error : "")
                  }}
                  startLoading={this.startLoading}
                  finishLoading={this.finishLoading}
                  form={this.getForm()}
               />
               <div className='moon btn-floating btn-large'>
                  <i
                     onClick={() => this.openModal()}
                     className="material-icons">
                     perm_identity</i>
                  </div></li>}</ul>
   }
}
