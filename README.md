## Screeps

*License: [GPL v3](https://github.com/thislooksfun/screeps/blob/master/LICENSE.md)*

Just a small repo to host my [Screeps](http://screeps.com) scripts.

If you want to run these yourself, add a file `secret.js` (or `secret.coffee`) to the main directory, with the following contents:

`secrets.js`:
```javascript
module.exports = {
  username: '{Your Screeps username}',
  password: '{Your Screeps password}'
}
```

`secrets.coffee`:
```coffeescript
module.exports =
  username: '{Your Screeps username}'
  password: '{Your Screeps password}'
```

Then run `./upload`.

If you want to upload to a branch other than `default`, run `./upload [branch]`