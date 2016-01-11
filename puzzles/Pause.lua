local widget = require( "widget" );
local composer = require("composer");
local scene = composer.newScene();
local pauseComponentsPath = "res/pause components/";
local screenWidth, screenHeight = display.contentWidth, display.contentHeight;


function initFonPicture(sceneGroup)
	local fon = display.newImage(pauseComponentsPath.."transp.png");
	fon.width = (3.345/5)*screenWidth; fon.height = (3.10/5)*screenHeight;
	fon.x = display.contentCenterX; fon.y = display.contentCenterY;
	
	sceneGroup:insert(fon);
end;

function startNewGame(event)
	if event.phase == "ended" then
		audio.play(composer.getVariable("click"));
		composer.hideOverlay("slideUp", 400);
		composer.gotoScene("Game");
	end;
end;

function initPlayAgainButton(sceneGroup)
	local playAgainButton = widget.newButton(
		{
			width = (3.345/10)*screenWidth,
			height = (3.345/40)*screenWidth,
			defaultFile = pauseComponentsPath.."play again start.png",
			overFile = pauseComponentsPath.."play again over.png",
			onEvent = startNewGame
		}
	)
	playAgainButton.x = 0.671875*screenWidth; playAgainButton.y = 0.7444444*screenHeight;
	sceneGroup:insert(playAgainButton);
end;

function gotoMenuOnTimer()
	composer.gotoScene("Menu", "slideRight", 1000);
end;

function gotoMenu(event)
	if event.phase == "ended" then
		audio.play(composer.getVariable("click"));
		composer.hideOverlay("slideUp", 400);
		local timer = timer.performWithDelay(200, gotoMenuOnTimer);
	end;
end;

function initMenuButton(sceneGroup)
	local menuButton = widget.newButton(
		{
			width = (3.345/10)*screenWidth,
			height = (3.345/40)*screenWidth,
			defaultFile = pauseComponentsPath.."menu start.png",
			overFile = pauseComponentsPath.."menu over.png",
			onEvent = gotoMenu
		}
	)
	menuButton.x =0.330208333*screenWidth; menuButton.y = 0.7444444*screenHeight;
	sceneGroup:insert(menuButton);
end;

function initTimeText(sceneGroup)
	local timeText = display.newImage(pauseComponentsPath.."time.png");
	timeText.width = (3.345/10)*screenWidth; timeText.height = (3.345/40)*screenWidth;
	timeText.x = display.contentCenterX; timeText.y = display.contentCenterY - (3.10/13)*screenHeight;
	
	sceneGroup:insert(timeText);
end;

function printTime(sceneGroup)
	local time = composer.getVariable("time");
	local minutes, seconds = "", "";
	
	if (#tostring(math.floor(time/60%60)) < 2) then
		minutes = "0";
	end;	
	minutes = minutes..tostring(math.floor(time/60));
	
	if(#tostring(time%60) < 2) then
		seconds = "0";
	end;
	seconds = seconds..tostring(time%60);
	
	local options = 
	{
		text = minutes..":"..seconds,     
		x = display.contentCenterX,
		y = display.contentCenterY,
		font = native.systemFontBold,   
		fontSize = 1/5*screenWidth,
	}
	
	local displayTime = display.newText(options);
	sceneGroup:insert(displayTime);
end;

function scene:create( event )
    local sceneGroup = self.view
	initFonPicture(sceneGroup);	
	initPlayAgainButton(sceneGroup);
	initMenuButton(sceneGroup);
	initTimeText(sceneGroup);
	printTime(sceneGroup);
end

scene:addEventListener( "create", scene )

return scene