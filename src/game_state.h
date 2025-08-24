
#pragma once

#include "common.h"

struct GameState
{
    f32 cam_pos_x;
    f32 cam_pos_y;
    f32 cam_pos_z;

    f32 cam_forward_x;
    f32 cam_forward_y;
    f32 cam_forward_z;

    u32 num_cubes;
    f32 cube_pos_x[3];
    f32 cube_pos_y[3];
    f32 cube_pos_z[3];
};

void init_game_state(struct GameState* game_state);

void update_game_state(struct GameState* game_state, const struct GameState* prev_game_state);
