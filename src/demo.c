#include <math.h>

#include "demo.h"
#include "input.h"
#include "entity.h"
#include "ppu/ppu.h"

#include "engine/maths.h"
#include "engine/camera.h"
#include "engine/entity.h"
#include "engine/draw_screen.h"
#include "engine/player_controller.h"
#include "engine/sprite_controller.h"



#define HH_DEMO_BALL_COUNT 2
hh_s_ppu_loc_fam_entry g_hh_demo_balls[HH_DEMO_BALL_COUNT];

hh_s_entity_player g_hh_player_1 = {
	.pos_x		 = 11000, 
	.pos_y		 = 10000,
	.radius		 = 4,
	.speed		 = 100,
	.air_speed   = 80,
	.direction_x = 1,
	.accelY 		 = 0,
	.accelX 		 = 0,
	.rotation	 = 8,
	.in_air		 = false,
};

hh_s_entity_player g_hh_enemy_1 = {
	.pos_x		 = 18000, 
	.pos_y		 = 18000,
	.radius		 = 4,
	.speed		 = 100,
	.air_speed   = 80,
	.direction_x = 1,
	.accelY 		 = 0,
	.accelX 		 = 0,
	.rotation	 = 8,
	.in_air		 = false,
};

void playerTest();
hh_s_entity_player ent_coll(hh_s_entity_player tempPlayer, hh_s_entity_player tempEntity);
bool distance_circles (hh_s_entity_player tempPlayer, hh_s_entity_player tempEntity);


void hh_player_movement();
hh_s_entity_player hh_enemy_movement(hh_s_entity_player tempEntity);

int hh_background_collision_x(hh_s_entity_player tempEntity);
hh_s_entity_player hh_background_collision_y_player(hh_s_entity_player tempEntity);

uint16_t g_hh_pos_x = 1000; // 0b0000 0001 0011 0110
uint16_t g_hh_pos_y;
uint8_t g_hh_left  = 0;
uint8_t g_hh_right = 0;
uint8_t g_hh_up	  = 0;
uint8_t g_hh_down  = 0;
uint8_t g_hh_pos_x_bit[2];
uint8_t g_hh_pos_y_bit[2];
uint8_t g_hh_data_send[3];
int g_hh_tile_size = 8;
int g_hh_tile_y;

typedef struct {
	vec2 pos;
	uint8_t idx;
}hh_s_tiles;


hh_entity hh_g_player, hh_g_player_new;
void hh_demo_setup() {

	hh_setup_palettes();
	hh_setup_screen();

	// load sprites
	hh_ppu_update_sprite(0, HH_DBG_SPRITE_BALL);
	hh_ppu_update_sprite(1, HH_DBG_SPRITE_CHECKERBOARD);

	// background pattern
	hh_ppu_update_color(0, 1, (hh_ppu_rgb_color_t){0x4, 0x4, 0x4});
	for (unsigned i = 0; i < HH_PPU_BG_CANVAS_TILES_H * HH_PPU_BG_CANVAS_TILES_V; i++) {

		hh_ppu_update_background(i, (hh_s_ppu_loc_bam_entry){
			.horizontal_flip = false,
			.vertical_flip	 = false,
			.palette_index	 = 0,
			.tilemap_index	 = 1,
		});


	}

	// cool colors
	hh_ppu_update_color(1, 1, (hh_ppu_rgb_color_t){0xf, 0x0, 0xf});
	hh_ppu_update_color(2, 1, (hh_ppu_rgb_color_t){0xf, 0xf, 0xf});
	hh_ppu_update_color(3, 1, (hh_ppu_rgb_color_t){0xf, 0x0, 0x0});
	hh_ppu_update_color(4, 1, (hh_ppu_rgb_color_t){0x0, 0xf, 0xf});
	hh_ppu_update_color(5, 1, (hh_ppu_rgb_color_t){0x0, 0x0, 0xf});

	// balls
	for (unsigned i = 0; i < HH_DEMO_BALL_COUNT; i++) {
		g_hh_demo_balls[i].horizontal_flip = false;
		g_hh_demo_balls[i].vertical_flip   = false;
		g_hh_demo_balls[i].palette_index   = i + 1;
		g_hh_demo_balls[i].tilemap_index   = 0;
	}

}

void hh_demo_loop(unsigned long frame) {

	 hh_player_movement();

	//playerTest();
	
	//hh_player_actions();
// input testing (no hitbox stuff)


	// g_hh_player_1.pos_x  += ((-1 * g_hh_controller_p1.dpad_left) + (1 * g_hh_controller_p1.dpad_right)) * g_hh_player_1.speed; // -1 = L || 1 == R
	// g_hh_player_1.pos_y  += ((-1 * g_hh_controller_p1.dpad_up) + (1 * g_hh_controller_p1.dpad_down)) * g_hh_player_1.speed; // -1 = D || 1 == U

	// ent_coll(g_hh_player_1,  g_hh_enemy_1);


	// adjust map size
	g_hh_pos_x = g_hh_player_1.pos_x / 100;
	g_hh_pos_y = g_hh_player_1.pos_y / 100;

	
	// update player sprite on ppu
	g_hh_demo_balls[0].position_x = g_hh_pos_x;
	g_hh_demo_balls[0].position_y = g_hh_pos_y;

	g_hh_demo_balls[1].position_x = g_hh_enemy_1.pos_x / 100;
	g_hh_demo_balls[1].position_y = g_hh_enemy_1.pos_y / 100;;
	hh_ppu_update_foreground(0, g_hh_demo_balls[0]);
	hh_ppu_update_foreground(1, g_hh_demo_balls[1]);

	// set background pattern position
	hh_ppu_update_aux((hh_s_ppu_loc_aux){
		.bg_shift_x = (frame / 2) % HH_PPU_SPRITE_WIDTH,
		.bg_shift_y = (frame / 8) % HH_PPU_SPRITE_HEIGHT,
		.fg_fetch	= 0,
		.sysreset	= 0,
	});
}

// void sendData(uint8_t address, uint16_t data) {
// 	uint8_t bitData[3];
// 	bitData[2] = data & 0xff;
// 	bitData[1] = (data >> 8);
// 	bitData[0] = address; // first byte is address
//
// 	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9, GPIO_PIN_RESET);
// 	HAL_SPI_Transmit(&hspi1, bitData, 3, 100); //2*8 bit data
// 	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9, GPIO_PIN_SET);
// }

void hh_player_movement() {
	int8_t directionX = (-1 * g_hh_controller_p1.dpad_left) + (1 * g_hh_controller_p1.dpad_right); // -1 = L || 1 == R
	int8_t directionY = (-1 * g_hh_controller_p1.dpad_up) + (1 * g_hh_controller_p1.dpad_down);	   // -1 = D || 1 == U

	if(g_hh_controller_p1.button_primary == 1 && g_hh_player_1.accelY == 0 && g_hh_player_1.in_air == false)
	{
		g_hh_player_1.accelY = 25;
	}


	uint8_t i, j;
	uint8_t rotation = 0; // 0-7

	// rotation calc
	for (i = -1; i < 2; i++) {
		for (j = -1; j < 2; j++) {
			if (directionX == i) {
				if (directionY == j) {
					if (i != 0 && j != 0) // dont update when player idle
					{
						g_hh_player_1.rotation = rotation;
					}
				}
			}
			rotation++;
		}
	}
	


	
	
	
	g_hh_player_1 = ent_coll(g_hh_player_1,  g_hh_enemy_1);

	if (g_hh_player_1.hit == true){
		g_hh_demo_balls[0].palette_index   = 5;
		g_hh_player_1.pos_x += g_hh_player_1.accelX * 100;
		g_hh_player_1.pos_y -= g_hh_player_1.accelY * 200;
		if(g_hh_player_1.accelX > 0){
			g_hh_player_1.accelX--;
		} else if (g_hh_player_1.accelX < 0){
			g_hh_player_1.accelX++;
		} else if (g_hh_player_1.accelX == 0){
			g_hh_player_1.hit = false;
		}
		g_hh_player_1.accelY--;
		
	} else {
		g_hh_demo_balls[0].palette_index   = 1;
				// X-axis calc
		if (directionX != 0) // update direction and position if player is not idle 
		{
			g_hh_player_1.direction_x = directionX;
			g_hh_player_1.pos_x = hh_background_collision_x(g_hh_player_1);
		}

		g_hh_player_1 = hh_background_collision_y_player(g_hh_player_1);

		// g_hh_player_1.pos_x  += ((-1 * g_hh_controller_p1.dpad_left) + (1 * g_hh_controller_p1.dpad_right)) * g_hh_player_1.speed; // -1 = L || 1 == R
		 g_hh_player_1.pos_y  += ((-1 * g_hh_controller_p1.dpad_up) + (1 * g_hh_controller_p1.dpad_down)) * g_hh_player_1.speed; // -1 = D || 1 == U
	}
	
	

}


int hh_background_collision_x(hh_s_entity_player tempEntity){
	// tile calc including radius and direction for background coliision

	uint16_t tileColX;
	uint16_t tileColY = (tempEntity.pos_y / 100) / 8;
	;

	// remaining space between grid and exact
	uint8_t modTileX;


		
	if (tempEntity.direction_x == 1) {
		tileColX = ((tempEntity.pos_x / 100) + tempEntity.radius) / g_hh_tile_size;
		modTileX = 799 -((tempEntity.pos_x + (100 * tempEntity.radius)) % (g_hh_tile_size*100));
	} else if (tempEntity.direction_x == -1) {
		tileColX = ((tempEntity.pos_x / 100) - tempEntity.radius )/ g_hh_tile_size;
		modTileX = (tempEntity.pos_x - (100 * tempEntity.radius)) % (g_hh_tile_size*100) ;
	}
	
	tileColY = (( tempEntity.pos_y / 100) + tempEntity.radius) / g_hh_tile_size; //bottom of player box
	
	if (HH_DEMO_HITBOX_TILEMAP[tileColY][tileColX + tempEntity.direction_x] != 1) {
		tileColY = (( tempEntity.pos_y / 100) - (tempEntity.radius)) / g_hh_tile_size; //bottom of player box
		if (HH_DEMO_HITBOX_TILEMAP[tileColY][tileColX + tempEntity.direction_x] != 1) {
			if(tempEntity.in_air== true){
				tempEntity.pos_x= tempEntity.pos_x + (tempEntity.direction_x * tempEntity.air_speed); // 80% of max speed if in air
			} else {
				tempEntity.pos_x= tempEntity.pos_x + (tempEntity.direction_x * tempEntity.speed); // 80% of max speed if in air
			}
		} else {
			if(tempEntity.in_air == true){
				if (modTileX < tempEntity.air_speed) {
					tempEntity.pos_x = tempEntity.pos_x + (tempEntity.direction_x * modTileX); // NEW x set
				} else {
					tempEntity.pos_x= tempEntity.pos_x + (tempEntity.direction_x * tempEntity.air_speed); //
				}
			} else {
				if (modTileX < g_hh_player_1.speed) {
					tempEntity.pos_x= tempEntity.pos_x + (tempEntity.direction_x * modTileX); // NEW x set
				} else {
					tempEntity.pos_x = tempEntity.pos_x + (tempEntity.direction_x * tempEntity.speed); // 
				}
			}
		}
	} else if (HH_DEMO_HITBOX_TILEMAP[tileColY][tileColX + tempEntity.direction_x] == 1) {
		if(tempEntity.in_air == true){
			if (modTileX < tempEntity.air_speed) {
				tempEntity.pos_x = tempEntity.pos_x + (tempEntity.direction_x * modTileX); // NEW x set
			} else {
				tempEntity.pos_x = tempEntity.pos_x + (tempEntity.direction_x * tempEntity.air_speed); //
			}
		} else {
			if (modTileX < g_hh_player_1.speed) {
				tempEntity.pos_x = tempEntity.pos_x + (tempEntity.direction_x * modTileX); // NEW x set
			} else {
				tempEntity.pos_x= tempEntity.pos_x + (tempEntity.direction_x * tempEntity.speed); // 
			}
		}
	}

	
	return tempEntity.pos_x;

}

hh_s_entity_player hh_background_collision_y_player(hh_s_entity_player tempEntity){

	uint16_t tileColX;
	uint16_t tileColY;
	
//
	// remaining space between grid and exact
		uint8_t modTileY;
	
	tileColY = ((tempEntity.pos_y / 100) + tempEntity.radius) / g_hh_tile_size; //bottom of player box
	tileColX = ((tempEntity.pos_x / 100) + tempEntity.radius) / g_hh_tile_size; //right of player
	modTileY = ((tempEntity.pos_y + (100 * tempEntity.radius)) % (g_hh_tile_size*100)); //bottom of box

	if(tempEntity.accelY <= 0){ //falling
		if(HH_DEMO_HITBOX_TILEMAP[tileColY+1][tileColX] != 1) {//check bottom right first
			tileColX = ((tempEntity.pos_x / 100) - tempEntity.radius) / g_hh_tile_size;
			if(HH_DEMO_HITBOX_TILEMAP[tileColY+1][tileColX] != 1)	{
				tempEntity.in_air = true;
				tempEntity.pos_y = tempEntity.pos_y - (tempEntity.accelY * 8) ;// NEW y set 
				if (tempEntity.accelY > -35){
					tempEntity.accelY--;
				}
			}
			else	{
				if(modTileY <= tempEntity.accelY * -8) {
					tempEntity.pos_y = tempEntity.pos_y + (modTileY) ;// NEW y set 
					tempEntity.accelY = 0;
					tempEntity.in_air = false;
				} else {
					tempEntity.pos_y = tempEntity.pos_y - (tempEntity.accelY * 8) ;// NEW y set 
				}				
			}
		} else {
			if(modTileY <= tempEntity.accelY * -8) {
				tempEntity.pos_y = tempEntity.pos_y + (modTileY) ;// NEW y set 
				tempEntity.accelY = 0;
				tempEntity.in_air = false;
			} else {
				tempEntity.pos_y = tempEntity.pos_y - (tempEntity.accelY * 8) ;// NEW y set 
			}
		}
	} else { //jumping
		tempEntity.in_air = true;
		tileColY = (( tempEntity.pos_y / 100) - tempEntity.radius) / g_hh_tile_size; //top of player box
		modTileY = 800 -((tempEntity.pos_y + (100 * tempEntity.radius)) % (g_hh_tile_size*100)); //top of box
			if(HH_DEMO_HITBOX_TILEMAP[tileColY-1][tileColX] != 1) {//check top right first
				tileColX = ((tempEntity.pos_x / 100) - tempEntity.radius) / g_hh_tile_size;
				if(HH_DEMO_HITBOX_TILEMAP[tileColY-1][tileColX] != 1)	{
					tempEntity.pos_y = tempEntity.pos_y - (tempEntity.accelY * 8) ;// NEW y set 
					tempEntity.accelY--;
				}	else	{
				if(modTileY <= tempEntity.accelY * 8) {
					tempEntity.pos_y = tempEntity.pos_y - (modTileY-1) ;// NEW y set 
					tempEntity.accelY = 0;
				} else {
					tempEntity.pos_y = tempEntity.pos_y - (tempEntity.accelY * 8) ;
					tempEntity.accelY--;
				}
				}
			} else {
				if(modTileY <= tempEntity.accelY * 8) {
					tempEntity.pos_y = tempEntity.pos_y - (modTileY-1) ;// NEW y set 
					tempEntity.accelY = 0;
				} else {
					tempEntity.pos_y = tempEntity.pos_y - (tempEntity.accelY * 8) ;// NEW y set 
					tempEntity.accelY--;
				}
			}
		
	}
	return tempEntity;
}

hh_s_entity_player hh_enemy_movement(hh_s_entity_player tempEntity){

//g_hh_demo_balls[0].palette_index   = 3;
return tempEntity;

}

void playerTest(){



	g_hh_player_1 = ent_coll(g_hh_player_1,  g_hh_enemy_1);

	if (g_hh_player_1.hit == true){
		g_hh_player_1.pos_x += g_hh_player_1.accelX * 100;
		g_hh_player_1.pos_y += g_hh_player_1.accelY * 100;
		if(g_hh_player_1.accelX > 0){
			g_hh_player_1.accelX--;
		} else if (g_hh_player_1.accelX < 0){
			g_hh_player_1.accelX++;
		} else if (g_hh_player_1.accelX == 0){
			g_hh_player_1.hit = false;
		}
		g_hh_player_1.accelY++;
		
	} else {
		 g_hh_player_1.pos_x  += ((-1 * g_hh_controller_p1.dpad_left) + (1 * g_hh_controller_p1.dpad_right)) * g_hh_player_1.speed; // -1 = L || 1 == R
		 g_hh_player_1.pos_y  += ((-1 * g_hh_controller_p1.dpad_up) + (1 * g_hh_controller_p1.dpad_down)) * g_hh_player_1.speed; // -1 = D || 1 == U
	}


}



hh_s_entity_player ent_coll(hh_s_entity_player tempPlayer, hh_s_entity_player tempEntity){
	

	bool collide;
	if(tempPlayer.hit == false) {

		collide = distance_circles( tempPlayer,  tempEntity);
	}
	

   
	double angle = 0;
	
	if (collide == true)
	{
		//g_hh_demo_balls[0].palette_index   = 5;
		//angle = atan2( tempEntity.pos_y - tempPlayer.pos_y, tempEntity.pos_x - tempPlayer.pos_x);
		if(tempPlayer.pos_x <= tempEntity.pos_x) //player left of enemy
		{
			tempPlayer.accelY = 5;
			tempPlayer.accelX = -8;
		}	else {
			tempPlayer.accelY = 5;
			tempPlayer.accelX = 8;
		}
		tempPlayer.hit = true;
		// lives--
		// ghost mode / invulnerable

	} else {
		//g_hh_demo_balls[0].palette_index   = 1;
		
	}

return tempPlayer;
}


bool distance_circles (hh_s_entity_player tempPlayer, hh_s_entity_player tempEntity){
	int a_squared = (tempPlayer.pos_x - tempEntity.pos_x) * (tempPlayer.pos_x - tempEntity.pos_x);
	int b_squared = (tempPlayer.pos_y - tempEntity.pos_y) * (tempPlayer.pos_y - tempEntity.pos_y);
	int c_squared = a_squared + b_squared; 
	int temp_player_r = tempPlayer.radius * 100;
	int temp_entity_r =  tempEntity.radius * 100;
	int radius = ( temp_entity_r + temp_player_r) * ( temp_entity_r + temp_player_r );

		if( c_squared <= radius ){
			return true;
		} else {
			return false;
		}
}

void collision_bounce (){

}
