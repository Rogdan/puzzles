local widget = require( "widget" );
local composer = require("composer");
local scene = composer.newScene();

local levelPath = "res/level 1/"
local gameComponentsPath = "res/game components/";
local soundPath = "res/sounds/"
local puzzleCatched, clickSound, levelCompleteSound;

local sceneGroup;
local puzzles = {};

local screenWidth = display.contentWidth;
local screenHeight = display.contentHeight;
local pictureWidth, pictureHeight = 1518, 926;

local fixedPuzzlesCounter, maxFixedPuzzlesCount;

local fon, helpPicture, currentMovingPuzzle;
local startCoordinateArray = {};

local startGameTime;

function setComponentFullScreen(component)
	local width = component.width;
	local height = component.height;
	
	component:scale(screenWidth/width, screenHeight/height);
	component.x = screenWidth/2; component.y = screenHeight/2;	
end;

function isWithinTheScreen(x, y)
	return x >= 10 and y >= 10 and x <= screenWidth - 10 and y <= screenHeight - 10;
end;

function isOnFinishPosition(eventX, eventY, component)
	local vector = {};
	vector.x = math.abs(eventX - component.mustBeOnX);
	vector.y = math.abs(eventY - component.mustBeOnY);
	
	local distance = math.sqrt(vector.x*vector.x + vector.y*vector.y);
	local maximalDistance = 15/100*component.width;
	return distance <= maximalDistance;
end;

function putOnFinishPosition(component)
	transition.moveTo(component, {x = component.mustBeOnX, y = component.mustBeOnY, time = 200});
	component:removeEventListener("touch", component);
	component.touch = nil;
	
	component:toBack();
	helpPicture:toBack();
	fon:toBack();
	
	fixedPuzzlesCounter = fixedPuzzlesCounter + 1;
end;

function checkGameEnd()
	if fixedPuzzlesCounter == maxFixedPuzzlesCount then
		audio.play(levelCompleteSound);
		local finishGameTime = os.date('*t');
		local time = os.time(finishGameTime) - os.time(startGameTime);
		composer.setVariable("time", time);
		local options = {
			isModal = true,
			effect = "fade",
			time = 1000,
		}
		composer.showOverlay("Pause", options);
		fixedPuzzlesCounter = 0;
	end;
end;

function catchComponent(component)
	component:toFront();
	audio.play(puzzleCatched);
	currentMovingPuzzle = component;
end;

function returnCatchedComponentOnTheStartMovingPoint()
	transition.moveTo(currentMovingPuzzle, {x = currentMovingPuzzle.startMovingX, y = currentMovingPuzzle.startMovingY, time = 350 });
	currentMovingPuzzle = nil;
end;

function setCatchedComponentOnThePoint(x, y)
	currentMovingPuzzle:toFront();
	currentMovingPuzzle.x = x; currentMovingPuzzle.y = y;
end;

function rememberStartMovingCoordinate(x, y)
	currentMovingPuzzle.startMovingX = x; currentMovingPuzzle.startMovingY = y;
end;

function isNoOneComponentCatched()
	return currentMovingPuzzle == nil;
end;

function puzzleMoving(self, event)
	local x = event.x;
	local y = event.y;
	if isNoOneComponentCatched() and event.phase == "began" then
		catchComponent(self);
		rememberStartMovingCoordinate(x, y);
		setCatchedComponentOnThePoint(x, y);
	elseif currentMovingPuzzle == self then
		if event.phase == "ended" then
			if isOnFinishPosition(x, y, currentMovingPuzzle) then
				putOnFinishPosition(currentMovingPuzzle);
				checkGameEnd();
			end;	
			currentMovingPuzzle = nil;
		elseif event.phase == "moved" then
			if isWithinTheScreen(x, y) then
				setCatchedComponentOnThePoint(x, y);
			else
				returnCatchedComponentOnTheStartMovingPoint();
			end;	
		end;		
	end;
end;

function initStartCoordinateArray()
	local startCoordinatesPath = system.pathForFile(levelPath.."start position.txt", system.BaseDirectory );
	local startCoordinatesFile, errorString = io.open(startCoordinatesPath, "r");
	for i = 1, 12 do
		local point = {};
		point.x = startCoordinatesFile:read("*n")*screenWidth;
		point.y = startCoordinatesFile:read("*n")*screenHeight;
		
		startCoordinateArray[i] = point;
	end;
	startCoordinatesFile:close();
end;

function getStartXY()
	local length = #startCoordinateArray;
	local posInArray = math.random(length);
	local x, y = startCoordinateArray[posInArray].x, startCoordinateArray[posInArray].y

	startCoordinateArray[posInArray] = startCoordinateArray[length];
	startCoordinateArray[length] = nil;
return x, y;
end;

function loadPuzzles()
	for i = 1, 3 do
		for j = 1, 4 do
			puzzles[#puzzles + 1] = display.newImage(levelPath..i..j..".png");
			puzzles[#puzzles]:scale((4/5)*screenWidth/pictureWidth, (4/5)*screenHeight/pictureHeight);
			sceneGroup:insert(puzzles[#puzzles]);
		end;
	end;
end;

function setOnetPuzzleProperties(puzzle, mustBeOnCoordinatesFile)
	local mustBeOnX, mustBeOnY = mustBeOnCoordinatesFile:read("*n")*screenWidth, mustBeOnCoordinatesFile:read("*n")*screenHeight;
	
	puzzle.x, puzzle.y = getStartXY();
	puzzle.mustBeOnX = mustBeOnX; puzzle.mustBeOnY = mustBeOnY;
	
	
	if puzzle.touch == nil then
		puzzle.touch = puzzleMoving;
		puzzle:addEventListener("touch", puzzle)
	end;
	
	puzzle.startMovingX = puzzle.x;
	puzzle.startMovingY = puzzle.y;
end;

function setPuzzlesProperties()
  local mustBeOnCoordinatesPath = system.pathForFile(levelPath.."end position.txt", system.BaseDirectory );
  local mustBeOnCoordinatesFile, errorString = io.open(mustBeOnCoordinatesPath, "r");
  initStartCoordinateArray();
  
  for i = 1, 12 do
	setOnetPuzzleProperties(puzzles[i], mustBeOnCoordinatesFile);
  end;
	
  mustBeOnCoordinatesFile:close();	
end;

function initFon()
	fon = display.newImage(gameComponentsPath.."table.jpg", screenWidth/2, screenWidth/2);
	setComponentFullScreen(fon);
end;

function initHelpPicture()
	helpPicture = display.newImage(gameComponentsPath.."back.jpg");
	helpPicture.width = (3.345/5)*screenWidth;
	helpPicture.height = (3.10/5)*screenHeight;
	helpPicture.x = screenWidth/2; helpPicture.y = screenHeight/2;
end;

function loadSounds()
	puzzleCatched = audio.loadSound(soundPath.."began.mp3");
	clickSound = audio.loadSound(soundPath.."click.wav");
	levelCompleteSound = audio.loadSound(soundPath.."success.mp3");
end;

function scene:create( event )
	maxFixedPuzzlesCount = 12;
	sceneGroup = self.view;
	
	loadSounds();
	fixedPuzzlesCounter = 0;
	
	initFon();
	sceneGroup:insert(fon);
	
	initHelpPicture();
	sceneGroup:insert(helpPicture);
	
	loadPuzzles(sceneGroup);	
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then
        setPuzzlesProperties();
    elseif ( phase == "did" ) then
		startGameTime = os.date('*t');
    end
end

scene:addEventListener( "create", scene );
scene:addEventListener( "show", scene );
return scene;