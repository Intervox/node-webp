[<img src="https://developers.google.com/speed/webp/images/webplogo.png" alt="WebP logo" align="right" />][webp]

  [webp]: https://developers.google.com/speed/webp/

[![Build Status][travis_icon]][travis]
[![Dependency Status][david_icon]][david]

  [travis_icon]: https://travis-ci.org/Intervox/node-webp.png?branch=latest
  [david_icon]: https://david-dm.org/Intervox/node-webp.png
  [travis]: https://travis-ci.org/Intervox/node-webp
  [david]: https://david-dm.org/Intervox/node-webp

node-webp
=========

Node.js wrapper for [cwebp][cwebp] and [dwebp][dwebp] binaries
from [WebP][webp] image processing utility.

  [cwebp]: https://developers.google.com/speed/webp/docs/cwebp
  [dwebp]: https://developers.google.com/speed/webp/docs/dwebp

## Installation

    npm install cwebp

### Getting latest version of [WebP][webp]

You can get latest WebP source, pre-compiled binaries and installation instructions
from its [official website][get_webp.1], or from its [downloads repository][get_webp.2].

Linux users may use [this installation script][get_webp.3]
to automatically download and install latest WebP binaries:

    curl -s https://raw.githubusercontent.com/Intervox/node-webp/latest/bin/install_webp | sudo bash

MacOS users may install WebP using [MacPorts][macports]:

    sudo port selfupdate
    sudo port install webp

If none of it suit your needs, you may [build the WebP utilities yourself][get_webp.5].

### Alternative ways to install [WebP][webp]

MacOS users may install webp `0.4.0` using [homebrew][homebrew]:

    brew install webp

You may also [install webp `0.3.x` as npm module][get_webp.4]:

    npm install webp

### Important: Using old WebP versions

Old versions of WebP (prior to `0.4.1`)
are not compatible with the latest `node-webp` version.

If you're using old version of WebP, please,
use [node-webp `0.1.x`][v0.1.10].

Check [this section][working-with-streams] for more info about
new streaming features of the latest WebP version.

  [get_webp.1]: https://developers.google.com/speed/webp/download
  [get_webp.2]: http://downloads.webmproject.org/releases/webp/index.html
  [get_webp.3]: https://github.com/Intervox/node-webp/blob/latest/bin/install_webp
  [get_webp.4]: https://www.npmjs.org/package/webp
  [get_webp.5]: https://developers.google.com/speed/webp/docs/compiling
  [macports]: http://guide.macports.org/
  [homebrew]: http://brew.sh/
  [working-with-streams]: #working-with-streams
  [v0.1.10]: https://github.com/Intervox/node-webp/tree/v0.1.10

## Usage

```js
var CWebp = require('cwebp').CWebp;
var DWebp = require('dwebp').DWebp;

var encoder = new CWebp(source_image);
var decoder = new DWebp(source_webp);
```

or

```js
// new is optional
var encoder = CWebp(source_image);
var decoder = DWebp(source_webp);
```

or

```js
// Backward-compatibility with cwebp@0.1.x
var CWebp = require('cwebp');
```

### Specifying path to cwebp binary

By default `node-webp` looks for `cwebp` and `dwebp` binary in your `$PATH`.

#### Specifying path as a constructor option

```js
var Webp = require('cwebp');
var binPath = require('webp').cwebp;

var webp = new Webp(source, binPath);
```

#### Changing default behaviour

```js
var CWebp = require('cwebp').CWebp;
CWebp.bin = require('webp').cwebp;

var encoder = new CWebp(source);
```

```js
var DWebp = require('cwebp').DWebp;
DWebp.bin = require('webp').dwebp;

var decoder = new DWebp(source);
```

**N.B.:** `webp` npm module provide old `webp 0.3.x` binaries.

### Available source types

When source is a string `node-webp` treats it as a file path.

```js
var CWebp = require('cwebp').CWebp;
var DWebp = require('dwebp').DWebp;

var encoder = new CWebp('original.jpeg');
var decoder = new DWebp('converted.webp');
```

It also accepts Buffers and Streams.

```js
var encoder = new CWebp(buffer);
```

```js
var decoder = new DWebp(stream);
```

Note that `node-webp` will start listening to the data in a source stream
only when `.write()`, `.stream()` or `.toBuffer()` is called.

### Encoding and decodind WebP images

```js
encoder.write('image.webp', function(err) {
    console.log(err || 'encoded successfully');
});
```

```js
decoder.write('image.png', function(err) {
    console.log(err || 'decoded successfully');
});
```

#### Getting output image as a Buffer

```js
decoder.toBuffer(function(err, buffer) {
    // ...
});
```

#### Getting output image as a readable Stream

```js
var stream = encoder.stream();

stream.pipe(destination);
stream.on('error', function(err) {
  // something bad happened
});
```

### Working with Streams

Different versions of WebP have different level of streaming support:

| Feature                | Older WebP versions | WebP `0.4.1` | node-webp `1.x` | node-webp `0.1.x` |
| ---------------------- | ------------------- | ------------ | --------------- | ----------------- |
| cwebp stdin streaming  | **_no_**            | **_no_**     | **_mock_**      | **_mock_**        |
| cwebp stdout streaming | **_no_**            | **_native_** | **_mock_**      | **_native_**      |
| dwebp stdin streaming  | **_no_**            | **_native_** | **_mock_**      | **_native_**      |
| dwebp stdout streaming | **_no_**            | **_native_** | **_mock_**      | **_native_**      |

**_mock_** means that `node-webp` acts as if the feature is supported,
mocking it using temporary files.

So, converting Stream into a Buffer with node-webp `0.x` will cause
two temporary files to be created and then removed
(one to store input stream, and another to read output buffer from).

Note that `node-webp` **_native_** streaming will work only
if your WebP version have **_native_** support for the corresponding stream,
while **_mock_** streaming will work with any version of WebP.

**IMPORTANT:** If you're using old version of WebP, please,
use [node-webp `0.1.x`][v0.1.10].

### Using promises

`node-webp` supports A+ promises.

```js
encoder.write('image.webp').then(function() {
    // ...
});
```

```js
encoder.toBuffer().then(function(buffer) {
    // ...
});
```

```js
decoder.stream().then(function(stream) {
    // ...
});
```

`node-webp` uses [when.js][when] library.

  [when]: https://github.com/cujojs/when

### Specifying conversion options

`node-webp` provides helper functions for most of `cwebp` and `dwebp` conversion options.
For the full list of available helpers see [methods.json][methods] file.

```js
encoder.quality(60);
decoder.tiff();
```

  [methods]: https://github.com/Intervox/node-webp/blob/latest/src/methods.json

#### Sending raw command

```js
encoder.command('-d', 'dump.pgm');
```

#### Verbose errors reporting

`node-webp` returns any error reported by `cwebp` or `dwebp`.
By default it uses standard error reporting mode,
but it's possible to enable `cwebp` verbose error reporting.

```js
var CWebp = require('cwebp').CWebp;

new CWebp(source).verbose().toBuffer(function (err, res) {
    // err.message contains verbose error
});
```

`dwebp` don't support verbose error reporting.

#### Changing default behaviour

```js
var CWebp = require('cwebp').CWebp;
CWebp.verbose = true;

new CWebp(source).toBuffer(function (err, res) {
    // err.message contains verbose error
});
```

## [Changelog][history]

  [history]: https://github.com/Intervox/node-webp/blob/latest/History.md
