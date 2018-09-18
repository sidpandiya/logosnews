RESEARCH

//CONFIG

		var passport = require('passport'); 									// auth
		var express = require('express');   									// route
		var firebase = require('firebase')  									// db
		var TwitterStrategy = require('passport-twitter').Strategy;				// twitter auth
		var FacebookStrategy = require('passport-facebook').Strategy;			// fb auth
		var GoogleStrategy = require('passport-google-oauth').OAuthStrategy;	// google oauth 
		var GoogleStrategy2 = require('passport-google-oauth').OAuth2Strategy;	// google oauth2
		var LinkedInStrategy = require('passport-linkedin').Strategy;			// linkedin auth
		var session = require('express-session');								// session middleware
		var bodyParser = require('body-parser');								// 
		var cookieParser = require('cookie-parser');							


		const router = express.Router();										//router

		passport.use(new FacebookStrategy({
		    clientID: FACEBOOK_APP_ID,
		    clientSecret: FACEBOOK_APP_SECRET,
		    callbackURL: "http://www.example.com/auth/facebook/callback"
		  },
		  function(accessToken, refreshToken, profile, done) {
		    User.findOrCreate(..., function(err, user) {
		      if (err) { return done(err); }
		      done(null, user);
		    });
		  }
		));

		passport.use(new TwitterStrategy({
		    consumerKey: TWITTER_CONSUMER_KEY,
		    consumerSecret: TWITTER_CONSUMER_SECRET,
		    callbackURL: "http://www.example.com/auth/twitter/callback"
		  },
		  function(token, tokenSecret, profile, done) {
		    User.findOrCreate(..., function(err, user) {
		      if (err) { return done(err); }
		      done(null, user);
		    });
		  }
		));

		passport.use(new GoogleStrategy({
		    consumerKey: GOOGLE_CONSUMER_KEY,
		    consumerSecret: GOOGLE_CONSUMER_SECRET,
		    callbackURL: "http://www.example.com/auth/google/callback"
		  },
		  function(token, tokenSecret, profile, done) {
		      User.findOrCreate({ googleId: profile.id }, function (err, user) {
		        return done(err, user);
		      });
		  }
		));

		passport.use(new GoogleStrategy2({
		    clientID: GOOGLE_CLIENT_ID,
		    clientSecret: GOOGLE_CLIENT_SECRET,
		    callbackURL: "http://www.example.com/auth/google/callback"
		  },
		  function(accessToken, refreshToken, profile, done) {
		       User.findOrCreate({ googleId: profile.id }, function (err, user) {
		         return done(err, user);
		       });
		  }
		));

		passport.use(new LinkedInStrategy({
		    consumerKey: LINKEDIN_API_KEY,
		    consumerSecret: LINKEDIN_SECRET_KEY,
		    callbackURL: "http://127.0.0.1:3000/auth/linkedin/callback"
		  },
		  function(token, tokenSecret, profile, done) {
		    User.findOrCreate({ linkedinId: profile.id }, function (err, user) {
		      return done(err, user);
		    });
		  }
		));



//ROUTES

		// Redirect the user to Facebook for authentication.  When complete,
		// Facebook will redirect the user back to the application at
		//     /auth/facebook/callback
		app.get('/auth/facebook', passport.authenticate('facebook'));

		// Facebook will redirect the user to this URL after approval.  Finish the
		// authentication process by attempting to obtain an access token.  If
		// access was granted, the user will be logged in.  Otherwise,
		// authentication has failed.
		app.get('/auth/facebook/callback',
		  passport.authenticate('facebook', { successRedirect: '/',
		                                      failureRedirect: '/login' }));

		// Redirect the user to Twitter for authentication.  When complete, Twitter
		// will redirect the user back to the application at
		//   /auth/twitter/callback
		app.get('/auth/twitter', passport.authenticate('twitter'));

		// Twitter will redirect the user to this URL after approval.  Finish the
		// authentication process by attempting to obtain an access token.  If
		// access was granted, the user will be logged in.  Otherwise,
		// authentication has failed.
		app.get('/auth/twitter/callback',
		  passport.authenticate('twitter', { successRedirect: '/',
		                                     failureRedirect: '/login' }));

		// GET /auth/google
		//   Use passport.authenticate() as route middleware to authenticate the
		//   request.  The first step in Google authentication will involve redirecting
		//   the user to google.com.  After authorization, Google will redirect the user
		//   back to this application at /auth/google/callback
		app.get('/auth/google',
		  passport.authenticate('google', { scope: 'https://www.google.com/m8/feeds' }));

		// GET /auth/google/callback
		//   Use passport.authenticate() as route middleware to authenticate the
		//   request.  If authentication fails, the user will be redirected back to the
		//   login page.  Otherwise, the primary route function function will be called,
		//   which, in this example, will redirect the user to the home page.
		app.get('/auth/google/callback', 
		  passport.authenticate('google', { failureRedirect: '/login' }),
		  function(req, res) {
		    res.redirect('/');
		  });

		// GET /auth/google
		//   Use passport.authenticate() as route middleware to authenticate the
		//   request.  The first step in Google authentication will involve
		//   redirecting the user to google.com.  After authorization, Google
		//   will redirect the user back to this application at /auth/google/callback
		app.get('/auth/google',
		  passport.authenticate('google', { scope: ['https://www.googleapis.com/auth/plus.login'] }));

		// GET /auth/google/callback
		//   Use passport.authenticate() as route middleware to authenticate the
		//   request.  If authentication fails, the user will be redirected back to the
		//   login page.  Otherwise, the primary route function function will be called,
		//   which, in this example, will redirect the user to the home page.
		app.get('/auth/google/callback', 
		  passport.authenticate('google', { failureRedirect: '/login' }),
		  function(req, res) {
		    res.redirect('/');
		  });

		app.get('/auth/linkedin',
		  passport.authenticate('linkedin'));

		app.get('/auth/linkedin/callback', 
		  passport.authenticate('linkedin', { failureRedirect: '/login' }),
		  function(req, res) {
		    // Successful authentication, redirect home.
		    res.redirect('/');
		  });





//PERMISSIONS

		app.get('/auth/facebook',
		    passport.authenticate('facebook', { scope: 'read_stream' })
		);

		app.get('/auth/linkedin',
  			passport.authenticate('linkedin', { scope: ['r_basicprofile', 'r_emailaddress'] }));


//TEMPLATES/LINKS

		<a href="/auth/facebook">Facebook</a>
		<a href="/auth/twitter">Twitter</a>
		<a href="/auth/google">Google</a>
		<a href="/auth/linkedin">LinkedIn</a>