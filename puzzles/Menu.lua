--Main menu scene. Init - initialize, for best reading.
local composer = require( "composer" );
local widget = require( "widget" );
local scene = composer.newScene();

local screenWidth = display.contentWidth;
local screenHeight = display.contentHeight;
local menuComponentsPath = "res/menu components/";

local clickSound = audio.loadSound("res/sounds/click.wav");
local puzzleText, fon, fonTexture, newGameButton;

function setComponentFullScreen(component)
	local width = component.width;
	local height = component.height;
	
	component:scale(screenWidth/width, screenHeight/height);
	component.x = screenWidth/2; component.y = screenHeight/2;	
end;

function startGame(event)
	if(event.phase == "ended" and newGameButton.isEnabled) then
		audio.play(clickSound);
		newGameButton.isEnabled = false;
		composer.gotoScene("Game", "slideLeft", 1000);
	end;
end;

function initNewGameButton()
	newGameButton = widget.newButton(
		{
			width = screenWidth/2.5,
			height = screenWidth/10,
			defaultFile = menuComponentsPath.."start.png",
			overFile = menuComponentsPath.."over.png",
			onEvent = startGame
		}
	)
	newGameButton.isEnabled = true;
	newGameButton.x = display.contentCenterX;
	newGameButton.y = 3/5*display.contentHeight;
end;

function initPuzzleText()
	puzzleText = display.newImage(menuComponentsPath.."puzzles.png");
	puzzleText.x = screenWidth/2; puzzleText.y = 1/6*screenHeight;
	puzzleText:scale(screenWidth/(2*puzzleText.width), screenWidth/(2*puzzleText.width));
	puzzleText.rotation = -10;
end;

function initFon()
	fon = display.newImage(menuComponentsPath.."main.jpg");
	setComponentFullScreen(fon);
end;

function scene:create( event )
    local sceneGroup = self.view;
	
	initFon();
	sceneGroup:insert(fon);
	
	initPuzzleText();
	sceneGroup:insert(puzzleText);
	
	initNewGameButton();
	sceneGroup:insert(newGameButton);
end;

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        newGameButton.isEnabled = true;
    end
end
 
-- Listener setup
scene:addEventListener( "create", scene );
scene:addEventListener("show", scene);
 
return scene