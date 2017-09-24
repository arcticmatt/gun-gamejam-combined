# Gun Game

This repository contains code for the server and client.

## Initialization

Run the following commands to clone the repository and load its submodules.
```
git clone https://github.com/arcticmatt/gun-gamejam-combined.git
cd gun-gamejam-combined
git submodule update --init
```

## Client
To run the client code, run:
```
cd gun-gamejam-client
love .
```

To run multiple client instances, run this command in multiple bash instances (or windows/tabs/whatever)

## Server
To run the server code, run:
```
cd gun-gamejam-server
lua s_main.lua
```
