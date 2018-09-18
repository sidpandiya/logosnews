<!-- LOGIN VIEW -->

<template>
  <div class="login">
    <h3>Sign In</h3>
    <button id="facebookButton" v-on:click="authenticateFB">Facebook</button>
    <button id="googleButton" v-on:click="authenticateGL">Google</button>
    <button id="twitterButton" v-on:click="authenticateTW">Twitter</button>
  </div>
</template>

<script>


export default {
  name: 'auth',
  data:{
    id: ''
  },
  methods: {
    authenticateFB: function() {
      var firebase = require('firebase')                                                          // require firebase
      require('firebase/auth');                                                                   // require auth
      require('firebase/database');                                                               // require db
      const configModule = require('../scripts/config');                                          // load config
      let config = configModule.config;             

      var provider = new firebase.auth.FacebookAuthProvider();                                    // create provider object
      provider.addScope('user_hometown');                                                         // fields we may want to record
      provider.addScope('user_location');                                                         // ""
      provider.addScope('user_gender');                                                           // ""
      provider.addScope('user_age_range');                                                        // ""

      firebase.auth().useDeviceLanguage();                                                        // use user's language
      firebase.auth().signInWithRedirect(provider);                                               // redirect

      firebase.auth().getRedirectResult().then(function(result) {                                 // get the result
        if (result.credential) {
          // This gives you a Facebook Access Token. You can use it to access the Facebook API.
          var token = result.credential.accessToken;
          // ...
        }
        // The signed-in user info.
        var user = result.user;
      }).catch(function(error) {                                                                  // error handling
        // Handle Errors here.
        var errorCode = error.code;
        var errorMessage = error.message;
        // The email of the user's account used.
        var email = error.email;
        // The firebase.auth.AuthCredential type that was used.
        var credential = error.credential;
      });

      firebase.auth().onAuthStateChanged(function(user) {                                         // if sign-in was successful
        if (user) {
          // User is signed in.
        } else {
          // No user is signed in.
        }
      });
    },
    authenticateGL: function() {
      console.log("gl")
    },
    authenticateTW: function() {
      console.log("tw")
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}

button{
  display: block;
  margin: auto;
  width: 20%;
  height: 50px;
}

#facebookButton{
  background-color: #3B5998;
  border-radius: 3px;
  color: white;
}

#googleButton{
  background-color: #DB4437;
  border-radius: 3px;
  color: white;
}

#twitterButton{
  background-color: #1DA1F2;
  border-radius: 3px;
  color: white;
}
</style>
