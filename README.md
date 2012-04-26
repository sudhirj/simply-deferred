#Simply Deferred
###A simplified version of jQuery's Deferred API for Node and the browser

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
* `deferred.reject()`
* `Deferred.when()`

In my experience, these methods cover over 90% of all use cases. I've also decided to drop `resolveWith` and `rejectWith` because [CoffeeScript](http://coffeescript.org/#fat_arrow) and [most](http://api.jquery.com/jQuery.proxy/), if not [all](http://documentcloud.github.com/underscore/#bind) JS libraries now provide easier ways to pre-bind your functions. This is allowed the code to be far simpler, smaller and better tested. 

###Usage with Zepto (coming soon)
Simply Deffered will also act as a plugin to [Zepto](http://zeptojs.com/). The absence of a Deferred library was one of the biggest reasons I've been holding back, so I thought it made sense to write one.  
