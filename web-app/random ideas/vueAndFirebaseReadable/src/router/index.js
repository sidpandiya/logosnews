import Vue from 'vue'
import Router from 'vue-router'

import Login from '@/components/Login'
import App from '@/components/App'

Vue.use(Router)

export default new Router({
  routes: [
    {path: '/'},
    {path: '/login', name: "Login", component: Login},
    {path: '/app', name: "App", component: App}
  ]
})
