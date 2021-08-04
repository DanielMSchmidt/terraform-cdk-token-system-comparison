#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const [dest, origin] = process.argv.slice(2);
const destContent = require(path.resolve(__dirname, dest));
const originContent = require(path.resolve(__dirname, origin));

const newDest = { ...destContent, ...originContent };
fs.writeFileSync(dest, JSON.stringify(newDest, null, 2));
