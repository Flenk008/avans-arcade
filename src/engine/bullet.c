#include "bullet.h"



// TODO: use hh_entity as bullet struct
void hh_shoot_bullet(vec2 player, vec_cor cam_pos, hh_entity* bullet){
	vec2 temp;
	if(g_hh_controller_p1.button_secondary){
		if(bullet->is_grounded){
			bullet->is_grounded=false;
			bullet->pos = player;
		}
	}
	else{
		if(!bullet->is_grounded){
			hh_update_bullet(bullet , cam_pos);
			hh_draw_bullet(*bullet);
		}
	}
	

}

void hh_update_bullet(hh_entity* bullet, vec_cor cam_pos){
	bullet->pos.x += 1;

	// update bullet sprite on ppu
	bullet->render.fam.position_x = (bullet->pos.x-cam_pos.x);
	bullet->render.fam.position_y = (bullet->pos.y-cam_pos.y);

}
void hh_draw_bullet(hh_entity bullet){
	hh_s_ppu_loc_fam_entry temp = bullet.render.fam;
	hh_ppu_update_foreground(10,temp);
}
