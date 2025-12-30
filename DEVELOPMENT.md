# Development Guide

This repository contains shell scripts. This guide outlines how to set up the development environment, run tests, and ensure code quality.

## Shell Scripts

### Testing Framework: Bats

We use [bats-core](https://github.com/bats-core/bats-core) (Bash Automated Testing System) for testing shell scripts. This allows us to verify that scripts perform as expected across different scenarios.

### Setting up Bats

`bats` is installed via `npm` to keep the dependency local to the project.

1. **Install Node.js**: Ensure you have Node.js and `npm` installed.
2. **Install the development dependencies**:

    ```sh
    cd /path/to/your/repo
    npm ci
    ```

#### Updating Node Modules

```sh
# Dependencies were added to package.json to facilitate this setup.
npm install --save-dev bats

# To update all packages to their latest versions based on the version ranges in package.json
npm update
```

### Running Shell Tests

To run all tests located in the `test/` directory:

```sh
npx bats test
```

This command will execute all `.bats` test files and report the results.
