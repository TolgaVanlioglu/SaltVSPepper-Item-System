enum Items
{
	Nothing,
	Gun,
	MachineGun,
	Wall,
	Bazooka,
	Laser,
	Count
}

enum ItemTypes
{
	Gun,
	Placeable
}

global.gDataItems[Items.Nothing][0] = ItemNONE;

//Guns
global.gDataItems[Items.Gun][0] = ItemGun;
global.gDataItems[Items.MachineGun][0] = ItemMachineGun;
global.gDataItems[Items.Bazooka][0] = ItemBazooka;

//Placeables
global.gDataItems[Items.Wall][0] = ItemWall;

//Default
function Item(_ownerid, _isplayer) constructor
{
	itemType = 0;
	itemName = "ITEM";
	itemId = 0;
	itemOwnerId = _ownerid;
	itemIsPlayer = _isplayer;
	
	itemActive = true;
	itemWaitTillUse = itemIsPlayer ? 60*1.5 : 0;
	
	itemCount = -1;
	itemCooldown = 0;
	itemCooldownMax = 10;
	
	itemSprite = sItemGun;
	itemGUIFrame = 0;
	
	//"Gun" items
	itemBulletSpeed = 2;

	//"Placeable" items
	itemPlaceRange = 24;
	itemPlaceX = -100;
	itemPlaceY = -100;
	itemPlaceLayer = "L_Ground";
	itemPlaceAnimSprite = -1;
	
	itemSpawnedObject = oProjBullet; //bullet or wall etc
	
	itemFrame = 0;
	
	itemAim = 0;
	itemX = _ownerid.x;
	itemY = _ownerid.y+8*_ownerid.image_yscale; //TAG SCALE (8)
	
	
	itemInpPressed = false;
	itemInpHeld = false;
	
	//"Draw" function
	static Draw = function(_color, _yscale)
	{
		if(itemActive)
		{
			if(itemType == ItemTypes.Gun)
			{
				draw_sprite_ext(itemSprite, itemFrame, itemX, itemY, 1, _yscale, itemAim, _color, 1);
			}
			else if(itemType == ItemTypes.Placeable)
			{
				draw_sprite_ext(itemSprite, itemFrame, itemPlaceX, itemPlaceY, 1, 1, 0, c_lime, 0.5);
				
				if(itemIsPlayer)
				{
					draw_set_color(c_lime);
					draw_circle(itemX, itemY, itemPlaceRange+18, 1);
					draw_set_color(c_white);
				}
			}
		}
	}
	
	//"Step" function > used for cooldowns etc
	static Step = function(_aim = 0, _x, _y)
	{
		itemInpPressed = false;
		itemInpHeld = false;
		
		Input();
		
		itemAim = _aim;
		
		itemX = _x;
		itemY = _y;
		
		if(itemType == ItemTypes.Placeable)
		{
			var _len = !itemIsPlayer ? itemPlaceRange : min(point_distance(_x, _y, global.gCursorX, global.gCursorY), itemPlaceRange);
			
			itemPlaceX = _x+dcos(_aim)*_len;
			itemPlaceY = _y-dsin(_aim)*_len;
		}
		
		if(itemInpPressed)
		{
			Pressed();
		}
		
		if(itemInpHeld)
		{
			Held();
		}
		
		if(itemCooldown > 0)
		{
			itemCooldown = max(itemCooldown - global.gGSpeed, 0);
		}
	}
	
	//"Held" function > used for when shoot is held
	static Held = function()
	{
		if(itemCooldown <= 0 && itemActive)
		{
			if(itemType == ItemTypes.Gun)
			{
				ActionGun();
			}
			else if(itemType == ItemTypes.Placeable)
			{
				ActionPlace();
			}
			
			itemCooldown = itemCooldownMax;
		}
	}
	
	//"ActionGun" function > used for the action e.g spawn bullet
	static ActionGun = function()
	{
	  fn_spawn_bullet(itemX, itemY, itemAim, itemBulletSpeed, !itemIsPlayer, itemOwnerId, itemSpawnedObject);
		
		if(itemCount > 0)
		{
			itemCount--;
			
			if(itemCount <= 0) itemActive = false;
		}
	}
	
	//"ActionPlace" function used for the action e.g spawn wall
	static ActionPlace = function()
	{
		with(instance_create_layer(itemPlaceX, itemPlaceY, itemPlaceLayer, itemSpawnedObject))
		{
			image_blend = oGameController.gameShiftColorFront;
			
			if(other.itemPlaceAnimSprite != -1)
			{
				fn_spawn_part_anim(other.itemPlaceAnimSprite, x, y, "L_AboveGround", image_blend, image_blend, 1, 1);
			}
		}
		
		if(itemCount > 0)
		{
			itemCount--;
			
			if(itemCount <= 0) itemActive = false;
		}
	}

//"Pressed" function used for the initial left click
	static Pressed = function()
	{
		itemCooldown = 0;
	}
	
	static Input = function()
	{
		if(itemIsPlayer)
		{
      //Gamepad input
			if(global.gGPMode)
			{
				itemInpPressed = fn_get_input_pressed(Inputs.AnyAim);
				itemInpHeld = fn_get_input_held(Inputs.AnyAim);
			}
			else
			{
				itemInpPressed = mouse_check_button_pressed(mb_left);
				itemInpHeld = mouse_check_button(mb_left);
			}
		}
		else
		{
			itemInpPressed = false;
			itemInpHeld = true;
		}
	}
}

//Items
function ItemNONE(_ownerid, _isplayer) : Item(_ownerid, _isplayer) constructor
{
	itemId = Items.Nothing;
	itemName = "Nothing";
	
	static Draw = function(){}
	static Step = function(_aim = 0, _x, _y){}
	static Held = function(){}
	static ActionGun = function(){}
	static ActionPlace = function(){}
	static Pressed = function(){}
	static Input = function(){}
}

function ItemGun(_ownerid, _isplayer) : Item(_ownerid, _isplayer) constructor
{
	itemId = Items.Gun;
	itemName = "Gun";
	itemSprite = sItemGun;
	itemCooldownMax = 10;
	itemBulletSpeed = 2; //TAG SCALE (min 2)
}

function ItemMachineGun(_ownerid, _isplayer) : Item(_ownerid, _isplayer) constructor
{
	itemId = Items.MachineGun;
	itemName = "Machine Gun";
	itemSprite = sItemMachineGun;
	itemCooldownMax = 4;
	itemBulletSpeed = 6;
}

function ItemBazooka(_ownerid, _isplayer) : Item(_ownerid, _isplayer) constructor
{
	itemId = Items.Bazooka;
	itemName = "Bazooka";
	itemSprite = sItemBazooka;
	itemCooldownMax = 60;
	itemBulletSpeed = 8;
	
	itemSpawnedObject = oProjRocket;
}

function ItemWall(_ownerid, _isplayer) : Item(_ownerid, _isplayer) constructor
{
	itemId = Items.Wall;
	itemName = "Wall";
	itemType = ItemTypes.Placeable;
	
	itemCount = 1;
	itemSprite = sPlaceableWall;
	itemPlaceLayer = "L_AboveGround";
	itemPlaceRange = 24;
	
	itemSpawnedObject = oPlaceableWall;
	itemPlaceAnimSprite = sPartSquare;
	itemCooldown = 60*1.5;
}

//Template
function ItemEXAMPLE(_ownerid, _isplayer) : Item(_ownerid, _isplayer) constructor
{
  //FUNCTIONS:
	//Step
	//Draw
	//Held
	//Pressed
	//ActionGun / ActionPlace
	//Input
  //InputAim
	
	//VARS TO CHANGE
	//itemType
	//itemName
	//itemCooldownMax
	//itemCount
	//itemSprite
	//itemSpawnedObject
}

//Give item to character
function fn_character_get_item(_charid, _item)
{
	if(!instance_exists(_charid))
	{
		return;
	}
	else
	{
		with(_charid)
		{
			if(object_index == oCharacterPlayer)
			{
				playerItem = new global.gDataItems[_item][0](id, true);
			}
			else if(object_index == oCharacterEnemy)
			{
				enemyItem = new global.gDataItems[_item][0](id, false);
			}
		}
	}
}
