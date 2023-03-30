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
#include "engine/level_const.h"

#include "GameLoop/startingScreen.h"
#include "GameLoop/gameplay.h"
#include "GameLoop/shop.h"


hh_g_all_levels hh_game;

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


hh_e_GameState hh_gameStates;
hh_entity hh_g_player, hh_g_player_new;
void hh_demo_setup() {

	hh_setup_palettes();
	// hh_setup_screen();
	hh_game = hh_init_game_levels();
}

void hh_demo_loop(unsigned long frame) {

	
	switch (hh_gameStates)
	{
	case hh_e_STATE_startingScreen:
		bool ret = hh_show_startingScreen();
		if(ret){
			hh_gameStates = hh_e_STATE_Shop;
		}	
		break;
	case hh_e_STATE_Shop:
		hh_Shop(&hh_gameStates);
		break;
	case hh_e_STATE_Gameplay:
		hh_gameplay(hh_game, &hh_gameStates);
		break;
	case hh_e_STATE_GameOver:
		// TODO:
		// function: show game over screen
		// function: after time goto high score
		break;
	case hh_e_STATE_HighScore:
		// TODO:
		// fucntion: show all previously scored points
		// function: button pressed goto starting screen
		break;
	default:
			hh_gameStates = hh_e_STATE_startingScreen;
		break;
	}
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






