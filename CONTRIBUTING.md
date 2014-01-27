## Setup

### Installation

```
npm install -g coffee-script
npm install -g mocha
npm install
```

## Contributing to Mongoose Rattle Plugin

### Reporting bugs

- Before opening a new issue, look for existing [issues](https://github.com/daemon1981/mongoose-rattle-plugin/issues) to avoid duplication. If the issue does not yet exist, [create one](https://github.com/daemon1981/mongoose-rattle-plugin/issues/new).
  - Please describe the issue you are experiencing, along with any associated stack trace.
  - Please post code that reproduces the issue, the version of mongoose-rattle-plugin, node version, and mongodb version.
  - _The source of this project is written in coffeescript, therefore your bug reports should be written in coffeescript_.
  - In general, adding a "+1" comment to an existing issue does little to help get it resolved. A better way is to submit a well documented pull request with clean code and passing tests.

### Requesting new features

- Before opening a new issue, look for existing [issues](https://github.com/daemon1981/mongoose-rattle-plugin/issues) to avoid duplication. If the issue does not yet exist, [create one](https://github.com/daemon1981/mongoose-rattle-plugin/issues/new).
- Please describe a use case for it
- it would be ideal to include test cases as well
- In general, adding a "+1" comment to an existing issue does little to help get it resolved. A better way is to submit a well documented pull request with clean code and passing tests.

### Fixing bugs / Adding features

- Before starting to write code, look for existing [issues](https://github.com/daemon1981/mongoose-rattle-plugin/issues). That way you avoid working on something that might not be of interest or that has been addressed already in a different branch. You can create a new issue [here](https://github.com/daemon1981/mongoose-rattle-plugin/issues/new).
  - _The source of this project is written in coffeescript, therefore your bug reports should be written in coffeescript_.
- Fork the [repo](https://github.com/daemon1981/mongoose-rattle-plugin) _or_ for small documentation changes, navigate to the source on github and click the [Edit](https://github.com/blog/844-forking-with-the-edit-button) button.
- Follow the general coding style of the rest of the project
- Write tests and make sure they pass (tests are in the [test](https://github.com/daemon1981/mongoose-rattle-plugin/tree/master/test) directory).

### Running the tests
- Open a terminal and navigate to the root of the project
- execute `npm install` to install the necessary dependencies
- execute `make test` to run the tests (we're using [mocha](http://visionmedia.github.com/mocha/))
  - or to execute a single test `T="-g 'some regexp that matches the test description'" make test`
  - any mocha flags can be specified with `T="..."`
