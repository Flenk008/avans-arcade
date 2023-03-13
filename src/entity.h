#pragma once

#include <stdint.h>
#include <stdbool.h>

typedef struct {
	uint16_t pos_x;
	uint16_t pos_y;
	uint8_t radius;
	uint8_t rotation; //45 degrees steps 0 == right 2 == down 4 == left 6 == up
	int8_t direction_x; //direction where its looking at in case no input;
	int16_t speed;	//10 default L/R MODifier
	int16_t air_speed;
	int16_t accelY;
	int16_t accelX;
	bool in_air;
	bool hit;
} hh_s_entity_player;
