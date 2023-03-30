#pragma once

#include "input.h"
#include "engine/draw_screen.h"
#include "engine/level_const.h"


#include <stdint.h>
#include <stdbool.h>

typedef enum {
	hh_e_shop_SHOW,
	hh_e_shop_Input,
	hh_e_shop_END,
} hh_e_ShopStates;


void hh_Shop(hh_e_GameState*);
