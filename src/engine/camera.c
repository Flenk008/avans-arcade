#include "engine/camera.h"

#include "ppu/consts.h"


vec_cor hh_update_camera(vec_cen new, vec2 min, vec2 max){

	//TODO: change floating point math to fix point math
	//TODO: remove magic number at y camera offset

	// new = vec_cen2cor(new,(vec2){.x=max.x/2,.y=max.y/2});
	new = vec_cen2cor((vec2){.x=new.x+(HH_PPU_SPRITE_WIDTH),.y=new.y+(HH_PPU_SPRITE_HEIGHT*8)},(vec2){.x=max.x/2,.y=max.y/2});
	// new.x = new.x << HH_MATH_FIXED_POINT;
	// new.y = new.y << HH_MATH_FIXED_POINT;
	static vec_cor old;
	// old.x = old.x << HH_MATH_FIXED_POINT;
	// old.y = old.y << HH_MATH_FIXED_POINT;

	// int16_t some = 0;
	// some = some <<= HH_MATH_FIXED_POINT-1;

	// Camera smoothing
	new.x = (int)((float)new.x*0.1f + (float)old.x*0.9f);
	new.y = (int)((float)new.y*0.1f + (float)old.y*0.9f);

	// old.x = old.x >> HH_MATH_FIXED_POINT;
	// old.y = old.y >> HH_MATH_FIXED_POINT;


	old.x = CLAMP(new.x,min.x,max.x);
	old.y = CLAMP(new.y,min.y,max.y);

	return old;
}

