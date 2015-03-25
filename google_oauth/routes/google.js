var express = require('express');
var router = express.Router();
var google = require('googleapis');
var config = require('../../dist/config').GOOGLE_OAUTH;
var oauth2Client = new google.auth.OAuth2(config.CLIENT_ID, config.CLIENT_SECRET, config.REDIRECT_URI);

router.get('/', function (req, res) {
    var scopes = [
        'https://www.googleapis.com/auth/adsense',
        'https://www.googleapis.com/auth/adexchange.seller'
    ];
    var url = oauth2Client.generateAuthUrl({
        access_type: 'offline', // 'online' (default) or 'offline' (gets refresh_token)
        scope: scopes // If you only need one scope you can pass it as string
    });
    res.redirect(url);
});

router.get('/oauth2callback', function (req, res) {
    var code = req.param("code");
    oauth2Client.getToken(code, function (err, tokens) {
        // Now tokens contains an access_token and an optional refresh_token. Save them.
        if (!err) {
            res.json(tokens);
        }
    });
});

module.exports = router;
