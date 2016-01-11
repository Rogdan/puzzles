------------------------------------------------
-- Puzzle v. 1.0 Created by Rogdan on 6.01.16 --
------------------------------------------------
local composer = require("composer");
local clickSound = audio.loadSound("res/sounds/click.wav");
composer.setVariable("click", clickSound);
composer.gotoScene("Menu");