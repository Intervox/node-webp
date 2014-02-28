node-webp
=========
[![Build Status](https://travis-ci.org/Intervox/node-webp.png?branch=master)](https://travis-ci.org/Intervox/node-webp)
[![Dependency Status](https://david-dm.org/Intervox/node-webp.png)](https://david-dm.org/Intervox/node-webp)

Node.js wrapper for [cwebp](https://developers.google.com/speed/webp/docs/cwebp) binary

## Installation

    npm install cwebp

### Requirements

[WebP](https://developers.google.com/speed/webp/) library should be installed and its binaries should be in `$PATH`.

## Usage

```js
var Webp = require('cwebp');

webp = new(source);
```

### Available source types

When source is a string `node-webp` treats it as a file path.

```js
var Webp = require('cwebp');

webp = new Webp('image.jpeg');
```

It also accepts Buffers and Streams.

### Converting image to WebP

```js
webp.write('image.webp', function(err) {
    console.log('converted');
});
```

#### Getting converted image as a Buffer

```js
webp.toBuffer(function(err, buffer) {
    // ...
});
```

#### Getting converted image as a readable Stream

```js
webp.stream(function(err, stream) {
    // ...
});
```

### Working with Streams and Buffers

Currently WebP library have no inner support for streaming, so it only works with files.

So, when Buffer or Stream is used `node-webp` creates a temporary file to store its content.

To prevent leaks `node-webp` creates temporary files only when `.write()`, `.stream()` or `.toBuffer()` is called.

It removes all temporary files after conversion, but before triggering a callback.

So, converting Stream into a Buffer will cause two temporary files to be created and then removed.

It also means that `node-webp` will start listening for new data in the source stream only when `.write()`, `.stream()` or `.toBuffer()` is called.

### Using promises

`node-webp` supports A+ promises.

```js
webp.write('image.webp').then(function() {
    // ...
});
```

```js
webp.toBuffer().then(function(buffer) {
    // ...
});
```

```js
webp.stream().then(function(stream) {
    // ...
});
```

`node-webp` use [when](https://github.com/cujojs/when) library.

### Specifying conversion options

`node-webp` provides helper function for most of `cwebp` conversion options. For the full list of available helpers see [methods.json](/src/methods.json) file.

#### Sending raw command

```js
webp.command('-d', 'dump.pgm');
```


## Running tests

Running test suite

    make test

Validating WebP installation

    make validate
