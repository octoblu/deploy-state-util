# deploy-state-util

[![Dependency status](http://img.shields.io/david/octoblu/deploy-state-util.svg?style=flat)](https://david-dm.org/octoblu/deploy-state-util)
[![devDependency Status](http://img.shields.io/david/dev/octoblu/deploy-state-util.svg?style=flat)](https://david-dm.org/octoblu/deploy-state-util)
[![Build Status](http://img.shields.io/travis/octoblu/deploy-state-util.svg?style=flat)](https://travis-ci.org/octoblu/deploy-state-util)

[![NPM](https://nodei.co/npm/deploy-state-util.svg?style=flat)](https://npmjs.org/package/deploy-state-util)

## Introduction

The utility for the [deploy-state-service](https://github.com/octoblu/deploy-state-service) and other deployment related services.

## Installing

```bash
npm install --global deploy-state-util
```

**For the octoblu team:** Make sure you have the latest dotfiles.

## Commands

### status

```bash
deploy-state status
```

List the status of a deployment. The project name and version will be auto assummed when inside a node project.

## watch

```bash
deploy-state watch
```

This is the alternative to `wump`.

Watch the status of a deployment. The project name and version will be auto assummed when inside a node project.

### list

```bash
deploy-state list
```

List the deployments of a project. The project name will be auto assummed when inside a node project.


## Example Configuration

**Location:** `~/.octoblu/depoy-state.json`

```json
{
  "deploy-state": {
    "hostname": "deploy-state.octoblu.com",
    "username": "...",
    "password": "..."
  },
  "governators": {
    "cluster-1": {
      "hostname": "governator-cluster-1.octoblu.com",
      "username": "...",
      "password": "..."
    },
    "cluster-2": {
      "hostname": "governator-cluster-2.octoblu.com",
      "username": "...",
      "password": "..."
    }
  },
  "service-state": {
    "cluster-1": {
      "hostname": "service-state-cluster-1.octoblu.com",
      "username": "...",
      "password": "..."
    },
    "cluster-2": {
      "hostname": "service-state-cluster-2.octoblu.com",
      "username": "...",
      "password": "..."
    }
  }
}
```

## License

The MIT License (MIT)

Copyright 2016 Octoblu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
