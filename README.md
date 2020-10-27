# Migrate LocalStorage

This plugin is an adaptation of
[jairemix](https://github.com/jairemix) [cordova-plugin-migrate-localstorage](https://github.com/jairemix/cordova-plugin-migrate-localstorage)
to allow for the migration of LocalStorage from `UIWebView` to `WKWebView` when updating an old app using [cordova ios v6.1.x](https://github.com/ionic-team/cordova-plugin-ionic-webview) and scheme.

All related files will be copied over automatically on first install so the user can simply pick up where they left of.

## How to use

In your `config.xml`, add a scheme (the new file name will depends on this scheme):
```xml
<preference name="scheme" value="app" />
<preference name="hostname" value="localhost" />
```

Simply add the plugin to your cordova project via the cli:
```sh
cordova plugin add https://github.com/viglino/cordova-plugin-migrate-localstorage
```

## Notes

- Thanks to [gerhardsletten](https://github.com/apache/cordova-ios/issues/906#issuecomment-672692414) 
to help finding correct path...

- LocalStorage files are only copied over once and only if no LocalStorage data exists for `WKWebView`
yet. This means that if you've run your app with `WKWebView` before this plugin will likely not work.

- Once the data is copied over, it is not being synced back to `UIWebView` so any changes done in
`WKWebView` will not persist should you ever move back to `UIWebView`. If you have a problem with this,
let us know in the issues section!

## Background

One of the drawbacks of migrating Cordova apps to `WKWebView` is that LocalStorage data does
not persist between the two. Unfortunately,
[cordova-plugin-wkwebview-engine](https://github.com/apache/cordova-plugin-wkwebview-engine) and
[cordova-plugin-ionic-webview](https://github.com/ionic-team/cordova-plugin-ionic-webview)
do not offer a solution for this out of the box.
