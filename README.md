[<img src="https://developers.google.com/speed/webp/images/webplogo.png" alt="WebP logo" align="right" />][webp]

  [webp]: https://developers.google.com/speed/webp/

[![NPM Package][repo_badge]][repo]
![Build Status][workflow_badge]

  [repo_badge]: https://img.shields.io/npm/v/cwebp.svg
  [workflow_badge]: https://github.com/Intervox/node-webp/actions/workflows/main.yml/badge.svg?branch=latest
  [repo]: https://www.npmjs.com/package/cwebp

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
to automatically download and install the latest WebP binaries:

    curl -s https://raw.githubusercontent.com/Intervox/node-webp/latest/bin/install_webp | sudo bash

MacOS users may install WebP using [homebrew][homebrew]:

    brew install webp

or [MacPorts][macports]:

    sudo port selfupdate
    sudo port install webp

If none of it suit your needs, you may [build the WebP utilities yourself][get_webp.4].

  [get_webp.1]: https://developers.google.com/speed/webp/download
  [get_webp.2]: http://downloads.webmproject.org/releases/webp/index.html
  [get_webp.3]: https://raw.githubusercontent.com/Intervox/node-webp/latest/bin/install_webp
  [get_webp.4]: https://developers.google.com/speed/webp/docs/compiling
  [macports]: http://guide.macports.org/
  [homebrew]: http://brew.sh/

## WebP versions compatibility

| `node-webp` version  | Fully compatible WebP versions | Partially compatible WebP versions |
| -------------------- | ------------------------------ | ---------------------------------- |
| `0.1.x`              | all versions                   | all versions                       |
| `1.x`                | `0.4.1` and later              | all versions                       |
| `2.x`                | `0.5.0` and later              | all versions                       |

## Usage

```js
var CWebp = require('cwebp').CWebp;
var DWebp = require('cwebp').DWebp;

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
var DWebp = require('cwebp').DWebp;

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

Note that `node-webp` will start consuming the input stream
only when `.write()`, `.stream()` or `.toBuffer()` is called.

### Encoding and decoding WebP images

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

### Using promises

`node-webp` supports promises.

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

### Specifying conversion options

`node-webp` provides helper functions for most of `cwebp` and `dwebp` conversion options.
For the full list of available helpers see [methods.json][methods] file.

```js
encoder.quality(60);
decoder.tiff();
```

  [methods]: https://github.com/Intervox/node-webp/blob/latest/methods.json

#### Sending raw command

```js
encoder.command('-d', 'dump.pgm');
```

#### Providing custom spawn options

```js
encoder.spawnOptions({detached: true});
```

## [Changelog][history]

  [history]: https://github.com/Intervox/node-webp/blob/latest/History.md
