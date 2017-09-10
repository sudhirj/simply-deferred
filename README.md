# Simply Deferred

### jQuery-like Deferred API for Node and the browser

*Simply Deferred is now feature complete. Bug fixes will be made, but no API changes are expected unless they're to ensure compliance with the jQuery API.*

## Installation
    npm install simply-deferred


## Usage
    var Deferred = require('simply-deferred').Deferred;
    var rendering = new Deferred();
    rendering.done(function(){
        console.log('Finished rendering');
    });

    //...

    rendering.resolve();

## API
Simply Deferred is fullly compatible with jQuery's API, so the [docs and usage](http://api.jquery.com/category/deferred-object/) are the same. Like the jQuery deferred API, it provides the following methods:

* `Deferred()`
* `deferred.state()`
* `deferred.done()`
* `deferred.fail()`
* `deferred.progress()`
* `deferred.always()`
* `deferred.promise()`
* `deferred.notify()`
* `deferred.notifyWith()`
* `deferred.resolve()`
* `deferred.resolveWith()`
* `deferred.rejectWith()`
* `deferred.reject()`
* `deferred.pipe()`
* `deferred.then()`
* `Deferred.when()`

### Collaborating
Please feel free to raise issues on [github.com/sudhirj/simply-deferred/issues](https://github.com/sudhirj/simply-deferred/issues) - both obvious bugs or incompatibilities with jQuery are welcome.

If you'd like contribute a fix or a feature, that would be even better. Please make sure all pull requests are accompanied by tests, though.

If you'd like to start work on a feature that is not part of the jQuery library, just raise an empty pull request and let's talk about it first - the goal here for this library to be a drop-in replacement for jQuery, with the same docs and API.

### Support
If you'd like to financially support the development of this library or just say thanks, you can send Bitcoin to `18TAaTamWaiv7cMK6FdbYeRzJUqBnECEah`. I'm also available to consult on how promises can improve your codebase - mail me at sudhir.j+github@gmail.com

### Usage with Zepto

**Zepto now has a [deferred module](http://zeptojs.com/#modules) available, so you might want to use that if Zepto is your primary reason for using Simply Deferred.**

Simply Deffered also acts as a plugin to [Zepto](http://zeptojs.com/). The absence of a Deferred library was one of the biggest reasons I've been holding back, so I thought it made sense to write one. Once you have both Zepto and Simply Deferred on your page, just do `Deferred.installInto(Zepto)` to set it up. The installation makes the following changes to bring it closer to jQuery:

* Aliases the `Deferred` constructor to `$.Deferred`.
* Aliases the `when` method to `$.when`.
* Wraps `$.ajax` to return a `promise`, which has only the following methods: `state()`, `done()`, `fail()` and `always()`. The arguments passed to the `done` and `fail` callbacks are the same ones passed to the `success` and `error` options.


