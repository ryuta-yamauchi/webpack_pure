require("@rails/ujs").start();
require("@rails/activestorage").start();
import "../../node_modules/@fortawesome/fontawesome-free/js/all";
require("../javascripts/channels");
require("@rails/actiontext");

import "../stylesheets/application";
const images = require.context("../images/", true);
import "../javascripts/common";
