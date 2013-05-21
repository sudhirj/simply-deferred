#Simply Deferred
###Simplified jQuery Deferred API for Node and the browser

##Installation
    npm install simply-deferred


##Usage
    var Deferred = require('simply-deferred').Deferred;    
    var rendering = new Deferred();
    rendering.done(function(){
        console.log('Finished rendering');
    });
    
    //...
    
    rendering.resolve();
    
##API
Simply Deferred is partially compatible with jQuery's API, so the [docs and usage](http://api.jquery.com/category/deferred-object/) are the same, except that they're restricted to the following methods:

* `Deferred()`
* `deferred.state()`
* `deferred.done()`
* `deferred.fail()`
* `deferred.always()`
* `deferred.promise()`
* `deferred.resolve()`
* `deferred.resolveWith()`
* `deferred.rejectWith()`
* `deferred.reject()`
* `deferred.pipe()`
* `deferred.then()`
* `when()`

###Usage with Zepto
Simply Deffered also acts as a plugin to [Zepto](http://zeptojs.com/). The absence of a Deferred library was one of the biggest reasons I've been holding back, so I thought it made sense to write one. Once you have both Zepto and Simply Deferred on your page, just do `Deferred.installInto(Zepto)` to set it up. The installation makes the following changes to bring it closer to jQuery:

* Aliases the `Deferred` constructor to `$.Deferred`.
* Aliases the `when` method to `$.when`.
* Wraps `$.ajax` to return a `promise`, which has only the following methods: `state()`, `done()`, `fail()` and `always()`. The arguments passed to the `done` and `fail` callbacks are the same ones passed to the `success` and `error` options.

###Collaborating
Please feel free to raise issues on github.com/sudhirj/simply-deferred/issues - both obvious bugs or incompatibilities with jQuery are welcome.

If you'd like contribute a fix or a feature, that would be even better. Please make sure all pull requests are accompanied by tests, though. 

If you'd like to start work on a feature that is not part of the jQuery library, let's talk about it first - the goal here for this library to be a drop in replacement for jQuery, with the same docs and API.

